//
//  StateInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 14/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct StateInfo {
    var stateKey: String
    var countryKey: String
    var name: String
    var latitude: Double
    var longitude: Double
    var geometry10mBytes: [UInt8]
    var geometry50mBytes: [UInt8]?
    var geometry110mBytes: [UInt8]?

    init(stateKey: String,
         name: String,
         geometry10mBytes: [UInt8],
         geometry50mBytes: [UInt8]?,
         geometry110mBytes: [UInt8]?,
         latitude: Double,
         longitude: Double,
         countryKey: String) {
        self.stateKey = stateKey
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.geometry10mBytes = geometry10mBytes
        self.geometry50mBytes = geometry50mBytes
        self.geometry110mBytes = geometry110mBytes
        self.countryKey = countryKey
    }

    var geometry10m: Geometry? {
        get {
            let bytes = geometry10mBytes
            return try? Geometry.init(wkb: Data(bytes))
        }
    }

    var geometry50m: Geometry? {
        get {
            if let bytes = geometry50mBytes {
                return try? Geometry.init(wkb: Data(bytes))
            }
            return nil
        }
    }

    var geometry110m: Geometry? {
        get {
            if let bytes = geometry110mBytes {
                return try? Geometry.init(wkb: Data(bytes))
            }
            return nil
        }
    }

    func country(geoDB: GeoDatabase) -> CountryInfo? {
        return geoDB.countryInfoFor(countryKey: countryKey)
    }
}
