//
//  ContinentInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 12/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct ContinentInfo {
    var name: String
    var geometryBytes: [UInt8]
    var minLatitude: Double
    var minLongitude: Double
    var maxLatitude: Double
    var maxLongitude: Double

    init(name: String,
         geometry: [UInt8],
         minLatitude: Double,
         minLongitude: Double,
         maxLatitude: Double,
         maxLongitude: Double) {
        self.name = name
        self.geometryBytes = geometry
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
}
