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

    init(name: String, geometry: [UInt8]) {
        self.name = name
        self.geometryBytes = geometry
    }

    var geometry: Geometry? {
        get {
            return try? Geometry.init(wkb: Data(bytes: geometryBytes))
        }
    }
}
