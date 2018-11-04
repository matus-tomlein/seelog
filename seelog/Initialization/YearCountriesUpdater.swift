//
//  YearCountriesUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

fileprivate class AggregatedCountry {
    var country: String
    var states = [String]()

    init(country: String) {
        self.country = country
    }

    func add(state: String) {
        if !states.contains(state) {
            states = states + [state]
        }
    }

    func has(state: String) -> Bool {
        return states.contains(state)
    }
}

fileprivate class AggregatedCountryList {
    var countries = [AggregatedCountry]()

    func has(country countryKey: String) -> Bool {
        let filtered = countries.filter { $0.country == countryKey }
        return filtered.count > 0
    }

    func has(country countryKey: String, andState stateKey: String) -> Bool {
        let filtered = countries.filter { $0.country == countryKey }
        if filtered.count == 0 { return false }

        return filtered[0].has(state: stateKey)
    }

    func add(country countryKey: String) -> AggregatedCountry {
        let filtered = countries.filter { $0.country == countryKey }
        if filtered.count > 0 { return filtered[0] }

        let country = AggregatedCountry(country: countryKey)
        countries.append(country)
        return country
    }
}

class YearCountriesUpdater {
    private var _countriesAggregated = [Int32: AggregatedCountryList]()
    private var _cumulativeCountriesAggregated = [Int32: AggregatedCountryList]()
    var sinceYear: Int32
    var sinceYearModel: Year?

    init(sinceKey: Int32,
         sinceAggregate: Year?) {
        self.sinceYear = sinceKey
        self.sinceYearModel = sinceAggregate

        self.initializeSegments()
    }

    var countriesAggregated: [Int32: [String: [String]]] {
        get { return countriesToPublic(_countriesAggregated) }
    }
    var cumulativeCountriesAggregated: [Int32: [String: [String]]] {
        get { return countriesToPublic(_cumulativeCountriesAggregated) }
    }

    func processNewPhoto(photo: Photo, key: Int32) {
        if let countryKey = photo.countryKey,
            let countries = _countriesAggregated[key] {
            let country = countries.add(country: countryKey)

            if let stateKey = photo.stateKey {
                country.add(state: stateKey)
            }

            for nextSegment in Helpers.yearsSince(key) {
                let countries = _cumulativeCountriesAggregated[nextSegment]

                if let stateKey = photo.stateKey {
                    if countries?.has(country: countryKey, andState: stateKey) ?? false {
                        break
                    }
                    countries?.add(country: countryKey).add(state: stateKey)
                } else {
                    if countries?.has(country: countryKey) ?? false {
                        break
                    }
                    let _ = countries?.add(country: countryKey)
                }
            }
        }
    }

    func updateModel(key: Int32, model: inout Year) {
        model.countries = countriesAggregated[key]!
        model.cumulativeCountries = cumulativeCountriesAggregated[key]!
    }

    private func initializeSegments() {
        for key in Helpers.yearsSince(sinceYear) {
            _countriesAggregated[key] = AggregatedCountryList()
            _cumulativeCountriesAggregated[key] = AggregatedCountryList()
        }

        if let firstAggregate = sinceYearModel,
            let countries = firstAggregate.countries,
            let cumulativeCountries = firstAggregate.cumulativeCountries {

            for country in countries.keys {
                let aggregatedCountry = _countriesAggregated[sinceYear]?.add(country: country)
                for state in countries[country] ?? [] {
                    aggregatedCountry?.add(state: state)
                }
            }

            for key in Helpers.yearsSince(sinceYear) {
                for country in cumulativeCountries.keys {
                    let aggregatedCountry = _cumulativeCountriesAggregated[key]?.add(country: country)
                    for state in cumulativeCountries[country] ?? [] {
                        aggregatedCountry?.add(state: state)
                    }
                }
            }
        }
    }

    private func countriesToPublic(_ countriesAggregated: [Int32: AggregatedCountryList]) -> [Int32 : [String : [String]]] {
        var result = [Int32: [String: [String]]]()
        for key in countriesAggregated.keys {
            var resultForKey = [String: [String]]()
            guard let countries = countriesAggregated[key] else { continue }

            for country in countries.countries {
                resultForKey[country.country] = country.states
            }

            result[key] = resultForKey
        }
        return result
    }
}
