//
//  GeoDatabase.swift
//  seelog
//
//  Created by Matus Tomlein on 09/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import SQLite

class GeoDatabase {
    var db : Connection? = nil
    let countries = Table("countries")
    let geohashCountries = Table("geohash_countries")
    let states = Table("states_provinces")
    let geohashStates = Table("geohash_states_provinces")
    
    let geohash = Expression<String>("geohash")
    let countryKey = Expression<String>("adm0_a3")
    let stateKey = Expression<String>("adm1_code")
    
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
