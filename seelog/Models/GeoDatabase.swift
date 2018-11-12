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
    let geohashCountries = Table("geohash_countries")
    let states = Table("states_provinces")
    let geohashStates = Table("geohash_states_provinces")
    let geohashCities = Table("geohash_cities")
    let cities = Table("cities")
    let timezones = Table("timezones")
    let geohashTimezones = Table("geohash_timezones")
    let continents = Table("continents")
    
    let geohash = Expression<String>("geohash")
    let name = Expression<String>("name")
    let latitude = Expression<Double>("latitude")
    let longitude = Expression<Double>("longitude")
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

    var countriesForStates = [String: String]()
    
    init() {
        if let filePath = Bundle.main.path(forResource: "generated", ofType: "sqlite") {
            do {
                self.db = try Connection(filePath)
            } catch {
                print("Failed to connect to geo database.")
            }
        }
    }
    
    func countryKeyFor(geohash: String) -> String? {
        let allGeohashes = getGeohashesOfAllLengths(geohash: geohash)

        if let db = self.db {
            do {
                let query = self.geohashCountries.where(allGeohashes.contains(self.geohash)).order(self.geohash.length.desc)
                if let item = try db.pluck(query) {
                    return item[self.countryKey]
                }
            } catch {
                print("Error querying geo database")
            }
        }
        
        return nil
    }

    func stateKeyFor(geohash gh: String) -> String? {
        let allGeohashes = getGeohashesOfAllLengths(geohash: gh)

        if let db = self.db {
            do {
                let query = self.geohashStates.where(allGeohashes.contains(self.geohash)).order(self.geohash.length.desc)
                if let item = try db.pluck(query) {
                    let stateKey = item[self.stateKey]
                    if stateKey == "" { return nil }
                    return stateKey
                }
            } catch {
                print("Error querying geo database")
            }
        }
        
        return nil
    }

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

    func timezoneFor(geohash gh: String) -> Int32? {
        let allGeohashes = getGeohashesOfAllLengths(geohash: gh)

        if let db = self.db {
            do {
                let query = self.geohashTimezones.where(allGeohashes.contains(self.geohash)).order(self.geohash.length.desc)
                if let item = try db.pluck(query) {
                    return Int32(item[self.timezoneId])
                }
            } catch {
                print("Error querying geo database")
            }
        }

        return nil
    }

    func cityKeysFor(geohash gh: String) -> [Int64] {
        let allGeohashes = getGeohashesOfAllLengths(geohash: gh)

        if let db = self.db {
            do {
                let query = self.geohashCities.where(allGeohashes.contains(self.geohash)).order(self.geohash.length.desc)
                return try db.prepare(query).map { $0[self.cityKey] }
            } catch {
                print("Error querying geo database")
            }
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
                        continent: item[continent],
                        region: item[region],
                        subregion: item[subregion])
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
                                     geometry10mBytes: item[geometry].bytes,
                                     geometry50mBytes: item[geometry50m]?.bytes,
                                     geometry110mBytes: item[geometry110m]?.bytes,
                                     latitude: item[latitude],
                                     longitude: item[longitude])

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
                                        places: item[places],
                                        geometry: item[geometry].bytes)
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
                                                      geometry: item[geometry].bytes)
                    cachedContinents[continentName] = continentInfo
                    return continentInfo
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
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
}
