//
//  TimezoneInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct TimezoneInfo {
    var timezoneId: Int32
    var name: String
    var value: Double
    var places: String
    var geometryBytes: [UInt8]
    var minLatitude: Double
    var minLongitude: Double
    var maxLatitude: Double
    var maxLongitude: Double

    init(timezoneId: Int32,
        name: String,
        value: Double,
        places: String,
        geometry: [UInt8],
        minLatitude: Double,
        minLongitude: Double,
        maxLatitude: Double,
        maxLongitude: Double) {
        self.timezoneId = timezoneId
        self.name = name
        self.places = places
        self.geometryBytes = geometry
        self.value = value
        self.minLatitude = minLatitude
        self.minLongitude = minLongitude
        self.maxLatitude = maxLatitude
        self.maxLongitude = maxLongitude
    }

    var geometry: Geometry? {
        get {
            return try? Geometry.init(wkb: Data(geometryBytes))
        }
    }
    
    var geometryDescription: GeometryDescription {
        GeometryDescription(
            geometry: geometry,
            minLatitude: minLatitude,
            minLongitude: minLongitude,
            maxLatitude: maxLatitude,
            maxLongitude: maxLongitude
        )
    }

    var uniqueName: String {
        return String(self.timezoneId)
    }
}
