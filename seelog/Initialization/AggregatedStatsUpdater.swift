//
//  AggregatedStatsUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 30/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

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

class AggregatedStatsUpdater<KeyType: Hashable, ModelType: Aggregate> {
    private var _countriesAggregated = [KeyType: AggregatedCountryList]()
    private var _cumulativeCountriesAggregated = [KeyType: AggregatedCountryList]()
    var citiesAggregated = [KeyType: [Int64]]()
    var cumulativeCitiesAggregated = [KeyType: [Int64]]()
    var cumulativeHeatmapWKTs = [KeyType: String]()
    var sinceKey: KeyType
    var sinceAggregate: ModelType?
    var getAllSegmentsSince: (KeyType) -> [KeyType]
    var heatmap: Geometry
    var knownGeohashes: Set<String>

    init(sinceKey: KeyType, sinceAggregate: ModelType?, knownGeohashes: Set<String>, getAllSegmentsSince: @escaping (KeyType) -> [KeyType]) {
        self.sinceKey = sinceKey
        self.sinceAggregate = sinceAggregate
        self.getAllSegmentsSince = getAllSegmentsSince
        self.knownGeohashes = knownGeohashes

        if let wkt = sinceAggregate?.cumulativeHeatmapWKT,
            let heatmap = Helpers.geometry(fromWKT: wkt) {
            self.heatmap = heatmap
        } else {
            self.heatmap = Helpers.blankWorldwidePolygon()
        }

        self.initializeSegments()
    }

    var countriesAggregated: [KeyType: [String: [String]]] {
        get { return countriesToPublic(_countriesAggregated) }
    }
    var cumulativeCountriesAggregated: [KeyType: [String: [String]]] {
        get { return countriesToPublic(_cumulativeCountriesAggregated) }
    }

    func processNewPhoto(photo: Photo, key: KeyType) {
        if let countryKey = photo.countryKey,
            let countries = _countriesAggregated[key] {
            let country = countries.add(country: countryKey)

            if let stateKey = photo.stateKey {
                country.add(state: stateKey)
            }

            for nextSegment in getAllSegmentsSince(key) {
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

        if let cityKeys = photo.cityKeys,
            var cities = citiesAggregated[key] {
            for cityKey in cityKeys {
                if !cities.contains(cityKey) {
                    cities.append(cityKey)
                }

                for nextSegment in getAllSegmentsSince(key) {
                    var cities = citiesAggregated[nextSegment]
                    if cities?.contains(cityKey) ?? false {
                        break
                    } else {
                        cities?.append(cityKey)
                    }
                }
            }
        }

        if let geohash = photo.geohash {
            if !knownGeohashes.contains(geohash) {
                if let result = Geohash.decode(hash: geohash),
                    let squarePolygon = Geometry.create("POLYGON((\(result.longitude.min) \(result.latitude.min), \(result.longitude.max) \(result.latitude.min), \(result.longitude.max) \(result.latitude.max), \(result.longitude.min) \(result.latitude.max), \(result.longitude.min) \(result.latitude.min)))"),
                    let newHeatmap = heatmap.difference(squarePolygon),
                    let wkt = newHeatmap.WKT {

                    self.heatmap = newHeatmap
                    knownGeohashes.insert(geohash)
                    for nextSegment in getAllSegmentsSince(key) {
                        cumulativeHeatmapWKTs[nextSegment] = wkt
                    }
                }
            }
        }
    }

    func updateModel(key: KeyType, model: inout ModelType) {
        model.countries = countriesAggregated[key]!
        model.cumulativeCountries = cumulativeCountriesAggregated[key]!
        model.cities = citiesAggregated[key] ?? [Int64]()
        model.cumulativeCities = cumulativeCitiesAggregated[key] ?? [Int64]()
        model.cumulativeHeatmapWKT = cumulativeHeatmapWKTs[key]
    }

    func joinCountryLists(oldList: [String: [String]], newList: [String: [String]]) -> [String: [String]] {
        var product = [String: [String]]()
        for country in newList.keys {
            product[country] = newList[country]
        }

        for country in oldList.keys {
            let oldStates = oldList[country] ?? []
            if var newStates = product[country] {
                for state in oldStates {
                    if !newStates.contains(state) {
                        newStates.append(state)
                    }
                }
            } else {
                product[country] = oldStates
            }
        }

        return product
    }

    private func initializeSegments() {
        for key in getAllSegmentsSince(sinceKey) {
            citiesAggregated[key] = []
            cumulativeCitiesAggregated[key] = []
            _countriesAggregated[key] = AggregatedCountryList()
            _cumulativeCountriesAggregated[key] = AggregatedCountryList()
            if let wkt = heatmap.WKT { cumulativeHeatmapWKTs[key] = wkt }
        }

        if let firstAggregate = sinceAggregate,
            let cities = firstAggregate.cities,
            let cumulativeCities = firstAggregate.cumulativeCities,
            let countries = firstAggregate.countries,
            let cumulativeCountries = firstAggregate.cumulativeCountries {

            for country in countries.keys {
                let aggregatedCountry = _countriesAggregated[sinceKey]?.add(country: country)
                for state in countries[country] ?? [] {
                    aggregatedCountry?.add(state: state)
                }
            }

            for country in cumulativeCountries.keys {
                for key in getAllSegmentsSince(sinceKey) {
                    let aggregatedCountry = _cumulativeCountriesAggregated[key]?.add(country: country)
                    for state in cumulativeCountries[country] ?? [] {
                        aggregatedCountry?.add(state: state)
                    }
                }
            }

            for city in cities {
                citiesAggregated[sinceKey]?.append(city)
            }

            for key in getAllSegmentsSince(sinceKey) {
                for city in cumulativeCities {
                    cumulativeCitiesAggregated[key]?.append(city)
                }
            }
        }
    }

    private func countriesToPublic(_ countriesAggregated: [KeyType: AggregatedCountryList]) -> [KeyType : [String : [String]]] {
        var result = [KeyType: [String: [String]]]()
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
