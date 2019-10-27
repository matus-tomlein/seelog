//
//  CountryInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 14/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct CountryInfo {
    var countryKey: String
    var name: String
    var continent: String
    var region: String
    var subregion: String
    var latitude: Double
    var longitude: Double
    var geometry10mBytes: [UInt8]
    var geometry50mBytes: [UInt8]?
    var geometry110mBytes: [UInt8]?

    init(countryKey: String,
         name: String,
         geometry10mBytes: [UInt8],
         geometry50mBytes: [UInt8]?,
         geometry110mBytes: [UInt8]?,
         latitude: Double,
         longitude: Double,
         continent: String,
         region: String,
         subregion: String) {
        self.countryKey = countryKey
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.geometry10mBytes = geometry10mBytes
        self.geometry50mBytes = geometry50mBytes
        self.geometry110mBytes = geometry110mBytes
        self.continent = continent
        self.region = region
        self.subregion = subregion
    }

    var geometry10m: Geometry? {
        get {
            return try? Geometry(wkb: Data(bytes: geometry10mBytes))
        }
    }

    var geometry50m: Geometry? {
        get {
            if let bytes = geometry50mBytes {
                return try? Geometry(wkb: Data(bytes: bytes))
            }
            return nil
        }
    }

    var geometry110m: Geometry? {
        get {
            if let bytes = geometry110mBytes {
                return try? Geometry(wkb: Data(bytes: bytes))
            }
            return nil
        }
    }
}
