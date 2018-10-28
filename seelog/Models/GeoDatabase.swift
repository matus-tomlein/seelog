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

    func countryInfoFor(countryKey ck: String) -> CountryInfo? {
        if let db = self.db {
            do {
                let query = countries.where(countryKey == ck)
                if let item = try db.pluck(query) {

                    return CountryInfo(
                        countryKey: ck, name:
                        item[name],
                        geometry10mBytes: item[geometry].bytes,
                        geometry50mBytes: item[geometry50m]?.bytes,
                        geometry110mBytes: item[geometry110m]?.bytes,
                        latitude: item[latitude],
                        longitude: item[longitude])
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }

    func stateInfoFor(stateKey sk: String) -> StateInfo? {
        if let db = self.db {
            do {
                let query = states.where(stateKey == sk)
                if let item = try db.pluck(query) {
                    return StateInfo(stateKey: sk,
                                     name: item[name],
                                     geometry10mBytes: item[geometry].bytes,
                                     geometry50mBytes: item[geometry50m]?.bytes,
                                     geometry110mBytes: item[geometry110m]?.bytes,
                                     latitude: item[latitude],
                                     longitude: item[longitude])
                }
            } catch {
                print("Error querying geo database")
            }
        }
        return nil
    }

    func cityInfoFor(cityKey key: Int64) -> CityInfo? {
        if let db = self.db {
            do {
                let query = cities.where(cityKey == key)
                if let item = try db.pluck(query) {
                    return CityInfo(cityKey: key, name: item[name], latitude: item[latitude], longitude: item[longitude])
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
