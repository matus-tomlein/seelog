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
         longitude: Double) {
        self.countryKey = countryKey
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.geometry10mBytes = geometry10mBytes
        self.geometry50mBytes = geometry50mBytes
        self.geometry110mBytes = geometry110mBytes
    }

    var geometry10m: Geometry? {
        get {
            let bytes = geometry10mBytes
            return Geometry.create(bytes, size: bytes.count)
        }
    }

    var geometry50m: Geometry? {
        get {
            if let bytes = geometry50mBytes {
                return Geometry.create(bytes, size: bytes.count)
            }
            return nil
        }
    }

    var geometry110m: Geometry? {
        get {
            if let bytes = geometry110mBytes {
                return Geometry.create(bytes, size: bytes.count)
            }
            return nil
        }
    }
}
