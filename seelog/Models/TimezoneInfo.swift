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
    var places: String
    var geometryBytes: [UInt8]

    init(timezoneId: Int32, name: String, places: String, geometry: [UInt8]) {
        self.timezoneId = timezoneId
        self.name = name
        self.places = places
        self.geometryBytes = geometry
    }

    var geometry: Geometry? {
        get {
            return Geometry.create(geometryBytes, size: geometryBytes.count)
        }
    }
}
