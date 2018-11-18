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
    var states = Set<String>()

    var numberOfStates: Int {
        get {
            return states.count
        }
    }

    init(country: String) {
        self.country = country
    }

    func add(state: String) {
        if !states.contains(state) {
            states.insert(state)
        }
    }

    func has(state: String) -> Bool {
        return states.contains(state)
    }
}

fileprivate class AggregatedCountryList {
    var countries = [String: AggregatedCountry]()

    var numberOfStates: Int {
        get {
            return countries.map({ $1.numberOfStates }).reduce(0, +)
        }
    }

    func has(country countryKey: String) -> Bool {
        return countries[countryKey] != nil
    }

    func has(country countryKey: String, andState stateKey: String) -> Bool {
        if let country = countries[countryKey] {
            return country.has(state: stateKey)
        }
        return false
    }

    func add(country countryKey: String) -> AggregatedCountry {
        if let country = countries[countryKey] {
            return country
        }
        let country = AggregatedCountry(country: countryKey)
        countries[countryKey] = country
        return country
    }
}

class YearCountriesUpdater {
    private var _countriesAggregated = [Int32: AggregatedCountryList]()
    private var _cumulativeCountriesAggregated = [Int32: AggregatedCountryList]()
    var sinceYear: Int32
    var sinceYearModel: Year?
    var geoDB: GeoDatabase
    var initializationState: CurrentInitializationState

    init(sinceKey: Int32,
         sinceAggregate: Year?,
         geoDB: GeoDatabase,
         initializationState: inout CurrentInitializationState) {
        self.sinceYear = sinceKey
        self.sinceYearModel = sinceAggregate
        self.initializationState = initializationState
        self.geoDB = geoDB

        self.initializeSegments()
    }

    var countriesAggregated: [Int32: [String: [String]]] {
        get { return countriesToPublic(_countriesAggregated) }
    }
    var cumulativeCountriesAggregated: [Int32: [String: [String]]] {
        get { return countriesToPublic(_cumulativeCountriesAggregated) }
    }

    func processNewPhoto(photo: Photo, key: Int32) {
        if let geohash = photo.geohash,
            let countryKey = geoDB.countryKeyFor(geohash: geohash),
            let countries = _countriesAggregated[key] {
            let country = countries.add(country: countryKey)

            let stateKey = geoDB.stateKeyFor(geohash: geohash)
            if let stateKey = stateKey {
                country.add(state: stateKey)
            }

            for nextSegment in Helpers.yearsSince(key) {
                let countries = _cumulativeCountriesAggregated[nextSegment]

                if let stateKey = stateKey {
                    if countries?.has(country: countryKey, andState: stateKey) ?? false {
                        break
                    }
                    countries?.add(country: countryKey).add(state: stateKey)
                    initializationState.numberOfCountries = countries?.countries.count ?? 0
                    initializationState.numberOfStates = countries?.numberOfStates ?? 0
                } else {
                    if countries?.has(country: countryKey) ?? false {
                        break
                    }
                    let _ = countries?.add(country: countryKey)
                    initializationState.numberOfCountries = countries?.countries.count ?? 0
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

            for country in countries.countries.values {
                resultForKey[country.country] = Array(country.states)
            }

            result[key] = resultForKey
        }
        return result
    }
}
