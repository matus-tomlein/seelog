//
//  GeoDatabase.swift
//  seelog
//
//  Created by Matus Tomlein on 09/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import SQLite
import GEOSwift

class GeoDatabase {
    var db : Connection? = nil
    let countries = Table("countries")
    let states = Table("states_provinces")
    let geohashCities = Table("geohash_cities")
    let cities = Table("cities")
    let timezones = Table("timezones")
    let geohashTimezones = Table("geohash_timezones")
    let continents = Table("continents")
    let geohashContinents = Table("geohash_continents")
    
    let geohash = Expression<String>("geohash")
    let name = Expression<String>("name")
    let latitude = Expression<Double>("latitude")
    let longitude = Expression<Double>("longitude")
    let minLatitude = Expression<Double>("min_latitude")
    let minLongitude = Expression<Double>("min_longitude")
    let maxLatitude = Expression<Double>("max_latitude")
    let maxLongitude = Expression<Double>("max_longitude")
    let countryKey = Expression<String>("adm0_a3")
    let stateKey = Expression<String>("adm1_code")
    let geometry = Expression<Blob>("geometry")
    let geometry50m = Expression<Blob?>("geometry_50m")
    let geometry110m = Expression<Blob?>("geometry_110m")
    let cityKey = Expression<Int64>("ogc_fid")
    let timezoneId = Expression<Int>("ogc_fid")
    let places = Expression<String>("places")
    let continent = Expression<String>("continent")
    let region = Expression<String>("region_un")
    let subregion = Expression<String>("subregion")
    let populationMin = Expression<Int>("pop_min")
    let populationMax = Expression<Int>("pop_max")
    let worldCity = Expression<Int>("worldcity")
    let megaCity = Expression<Int>("megacity")
    let value = Expression<Double>("value")
    let numberOfCountries = Expression<Int>("number_of_countries")
    let numberOfRegions = Expression<Int>("number_of_states")
    
    init() {
        if let filePath = Bundle.main.path(forResource: "generated", ofType: "sqlite") {
            do {
                self.db = try Connection(filePath)
            } catch {
                print("Failed to connect to geo database.")
            }
        }
    }

    private var cachedCountryKeysForGeohashes = [String: String]()
    private var cachedCountryGeohashes = Set<String>()
    func countryKeyFor(geohash: String) -> String? {
        let geohash2 = String(geohash.prefix(2))

        if !cachedCountryGeohashes.contains(geohash2) {
            cachedCountryGeohashes.insert(geohash2)

            guard let db = self.db else { return nil }
            let geohashCountries = Table("geohash_countries_" + geohash2)
            do {
                for item in try db.prepare(geohashCountries) {
                    cachedCountryKeysForGeohashes[item[self.geohash]] = item[self.countryKey]
                }
            } catch {
                print("Error querying geo database")
            }
        }
        for gh in getGeohashesOfAllLengths(geohash: geohash) {
            if let ck = cachedCountryKeysForGeohashes[gh] { return ck }
        }
        return nil
    }

    private var cachedStateKeysForGeohashes = [String: String]()
    private var cachedStateGeohashes = Set<String>()
    func stateKeyFor(geohash gh: String) -> String? {
        let geohash2 = String(gh.prefix(2))

        if !cachedStateGeohashes.contains(geohash2) {
            cachedStateGeohashes.insert(geohash2)

            guard let db = self.db else { return nil }

            let geohashStates = Table("geohash_states_provinces_" + geohash2)
            do {
                for item in try db.prepare(geohashStates) {
                    cachedStateKeysForGeohashes[item[self.geohash]] = item[self.stateKey]
                }
            } catch {
                print("Error querying geo database")
            }
        }
        for subgh in getGeohashesOfAllLengths(geohash: gh) {
            if let sk = cachedStateKeysForGeohashes[subgh] { return sk }
        }
        return nil
    }

    private var countriesForStates = [String: String]()
    func countryKeyFor(stateKey sk: String) -> String? {
        if let countryKey = countriesForStates[sk] {
            return countryKey
        }

        if let db = self.db {
            do {
                let query = states.where(stateKey == sk)
                if let item = try db.pluck(query) {
                    let ck = item[countryKey]
                    countriesForStates[sk] = ck
                    return ck
                }
            } catch {
                print("Error querying geo database")
            }
        }

        return nil
    }

    private var cachedTimezonesForGeohashes: [String: Int32]?
    func timezoneFor(geohash gh: String) -> Int32? {
        if cachedTimezonesForGeohashes == nil {
            guard let db = self.db else { return nil }
            cachedTimezonesForGeohashes = [:]
            do {
                for item in try db.prepare(self.geohashTimezones) {
                    cachedTimezonesForGeohashes?[item[self.geohash]] = Int32(item[self.timezoneId])
                }
            } catch {
                print("Error querying geo database")
            }
        }
        for subgh in getGeohashesOfAllLengths(geohash: gh) {
            if let id = cachedTimezonesForGeohashes?[subgh] { return id }
        }
        return nil
    }

    private var cachedContinentsForGeohashes: [String: String]?
    func continentFor(geohash gh: String) -> String? {
        if cachedContinentsForGeohashes == nil {
            guard let db = self.db else { return nil }
            cachedContinentsForGeohashes = [:]
            do {
                for item in try db.prepare(self.geohashContinents) {
                    cachedContinentsForGeohashes?[item[self.geohash]] = item[self.name]
                }
            } catch {
                print("Error querying geo database")
            }
        }
        for subgh in getGeohashesOfAllLengths(geohash: gh) {
            if let name = cachedContinentsForGeohashes?[subgh] { return name }
        }
        return nil
    }

    private var cachedCityKeysForGeohashes: [String: [Int64]]?
    func cityKeysFor(geohash gh: String) -> [Int64] {
        if cachedCityKeysForGeohashes == nil {
            guard let db = self.db else { return [] }
            cachedCityKeysForGeohashes = [:]
            do {
                for item in try db.prepare(self.geohashCities) {
                    let cityGeohash = item[self.geohash]
                    let cityKey = item[self.cityKey]
                    if var cityKeys = cachedCityKeysForGeohashes?[cityGeohash] {
                        cityKeys.append(cityKey)
                        cachedCityKeysForGeohashes?[cityGeohash] = cityKeys
                    } else {
                        cachedCityKeysForGeohashes?[cityGeohash] = [cityKey]
                    }
                }
            } catch {
                print("Error querying geo database")
            }
        }
        for subgh in getGeohashesOfAllLengths(geohash: gh) {
            if let key = cachedCityKeysForGeohashes?[subgh] { return key }
        }
        return []
    }

    private var cachedCountryInfos = [String: CountryInfo]()
    func countryInfoFor(countryKey ck: String) -> CountryInfo? {
        if let countryInfo = cachedCountryInfos[ck] {
            return countryInfo
        }
        else if let db = self.db {
            do {
                let query = countries.where(countryKey == ck)
                if let item = try db.pluck(query) {

                    let countryInfo = CountryInfo(
                        countryKey: ck, name:
                        item[name],
                        geometry10mBytes: item[geometry].bytes,
                        geometry50mBytes: item[geometry50m]?.bytes,
                        geometry110mBytes: item[geometry110m]?.bytes,
                        latitude: item[latitude],
                        longitude: item[longitude],
                        minLatitude: item[minLatitude],
                        minLongitude: item[minLongitude],
                        maxLatitude: item[maxLatitude],
                        maxLongitude: item[maxLongitude],
                        continent: item[continent],
                        region: item[region],
                        subregion: item[subregion],
                        numberOfRegions: item[numberOfRegions])
                    cachedCountryInfos[ck] = countryInfo
                    return countryInfo
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }

    private var cachedStateInfos = [String: StateInfo]()
    func stateInfoFor(stateKey sk: String) -> StateInfo? {
        if let stateInfo = cachedStateInfos[sk] {
            return stateInfo
        }
        else if let db = self.db {
            do {
                let query = states.where(stateKey == sk)
                if let item = try db.pluck(query) {
                    let stateInfo = StateInfo(stateKey: sk,
                                     name: item[name],
                                     continent: item[continent],
                                     geometry10mBytes: item[geometry].bytes,
                                     geometry50mBytes: item[geometry50m]?.bytes,
                                     geometry110mBytes: item[geometry110m]?.bytes,
                                     latitude: item[latitude],
                                     longitude: item[longitude],
                                     minLatitude: item[minLatitude],
                                     minLongitude: item[minLongitude],
                                     maxLatitude: item[maxLatitude],
                                     maxLongitude: item[maxLongitude],
                                     countryKey: item[countryKey])

                    cachedStateInfos[sk] = stateInfo
                    return stateInfo
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }

    private var cachedCityInfos = [Int64: CityInfo]()
    func cityInfoFor(cityKey key: Int64) -> CityInfo? {
        if let cityInfo = cachedCityInfos[key] { return cityInfo }
        if let db = self.db {
            do {
                let query = cities.where(cityKey == key)
                if let item = try db.pluck(query) {
                    let cityInfo = CityInfo(cityKey: key,
                                    name: item[name],
                                    stateKey: item[stateKey],
                                    continent: item[continent],
                                    latitude: item[latitude],
                                    longitude: item[longitude],
                                    countryKey: item[countryKey],
                                    populationMin: item[populationMin],
                                    populationMax: item[populationMax],
                                    worldCity: item[worldCity] > 0,
                                    megaCity: item[megaCity] > 0)
                    cachedCityInfos[key] = cityInfo
                    return cityInfo
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }

    private var cachedTimezones = [Int32: TimezoneInfo]()
    func timezoneInfoFor(timezoneId id: Int32) -> TimezoneInfo? {
        if let timezoneInfo = cachedTimezones[id] { return timezoneInfo }
        if let db = self.db {
            do {
                let query = timezones.where(timezoneId == Int(id))
                if let item = try db.pluck(query) {
                    let timezoneInfo = TimezoneInfo(timezoneId: Int32(item[timezoneId]),
                                        name: item[name],
                                        value: item[value],
                                        places: item[places],
                                        geometry: item[geometry].bytes,
                                        minLatitude: item[minLatitude],
                                        minLongitude: item[minLongitude],
                                        maxLatitude: item[maxLatitude],
                                        maxLongitude: item[maxLongitude])
                    cachedTimezones[id] = timezoneInfo
                    return timezoneInfo
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }

    private var cachedContinents = [String: ContinentInfo]()
    func continentInfoFor(name continentName: String) -> ContinentInfo? {
        if let continentInfo = cachedContinents[continentName] { return continentInfo }
        if let db = self.db {
            do {
                let query = continents.where(name == continentName)
                if let item = try db.pluck(query) {
                    let continentInfo = ContinentInfo(name: item[name],
                                                      geometry: item[geometry].bytes,
                                                      minLatitude: item[minLatitude],
                                                      minLongitude: item[minLongitude],
                                                      maxLatitude: item[maxLatitude],
                                                      maxLongitude: item[maxLongitude],
                                                      numberOfCountries: item[numberOfCountries])
                    cachedContinents[continentName] = continentInfo
                    return continentInfo
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }
    
    func allContinents() -> [ContinentInfo] {
        if let db = self.db {
            do {
                return try db.prepare(continents).map { row in
                    if let continentInfo = cachedContinents[row[name]] {
                        return continentInfo
                    } else {
                        let continentInfo = ContinentInfo(
                            name: row[name],
                            geometry: row[geometry].bytes,
                            minLatitude: row[minLatitude],
                            minLongitude: row[minLongitude],
                            maxLatitude: row[maxLatitude],
                            maxLongitude: row[maxLongitude],
                            numberOfCountries: row[numberOfCountries]
                        )
                        cachedContinents[row[name]] = continentInfo
                        return continentInfo
                    }
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return []
    }

    func getGeohashesOfAllLengths(geohash: String) -> [String] {
        var allGeohashes: [String] = []
        var newGeohash = String(geohash)
        while (newGeohash.count > 0) {
            allGeohashes.append(newGeohash)
            newGeohash = String(newGeohash.dropLast())
        }

        return allGeohashes
    }

    func clearCaches() {
        cachedCityKeysForGeohashes = nil
        cachedTimezonesForGeohashes = nil
        cachedCountryKeysForGeohashes.removeAll()
        cachedCountryGeohashes.removeAll()
        cachedStateKeysForGeohashes.removeAll()
        cachedStateGeohashes.removeAll()
        cachedCityInfos.removeAll()
        cachedContinents.removeAll()
        cachedStateInfos.removeAll()
        cachedTimezones.removeAll()
        cachedCountryInfos.removeAll()
    }
}
