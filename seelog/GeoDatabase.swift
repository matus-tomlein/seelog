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
        if let db = self.db {
            do {
                if let item = try db.pluck(self.geohashCountries.where(self.geohash == geohash)) {
                    return item[self.countryKey]
                } else if (geohash.count > 1) {
                    return countryKeyFor(geohash: String(geohash.dropLast()))
                }
            } catch {
                print("Error querying geo database")
            }
        }
        
        return nil
    }
    
    func stateKeyFor(geohash: String) -> String? {
        if let db = self.db {
            do {
                if let item = try db.pluck(self.geohashStates.where(self.geohash == geohash)) {
                    let stateKey = item[self.stateKey]
                    if stateKey == "" { return nil }
                    return stateKey
                } else if (geohash.count > 1) {
                    return stateKeyFor(geohash: String(geohash.dropLast()))
                }
            } catch {
                print("Error querying geo database")
            }
        }
        
        return nil
    }
}
