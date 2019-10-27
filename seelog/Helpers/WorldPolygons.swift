//
//  WorldPolygons.swift
//  seelog
//
//  Created by Matus Tomlein on 23/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

class WorldPolygons {
    static var _landsPolygon: GeometryConvertible?
    static var _waterPolygon: GeometryConvertible?
    static var landsPolygon: GeometryConvertible? {
        get {
            if _landsPolygon == nil { initLandsAndWaterPolygons() }
            return _landsPolygon
        }
    }
    static var waterPolygon: GeometryConvertible? {
        get {
            if _waterPolygon == nil { initLandsAndWaterPolygons() }
            return _waterPolygon
        }
    }

    static func initLandsAndWaterPolygons() {
        if let landsPath = Bundle.main.path(forResource: "lands", ofType: "wkt") {
            do {
                _landsPolygon = try MultiPolygon.init(wkt: String(contentsOfFile: landsPath,
                                                             encoding: String.Encoding.utf8))
                if let landsPolygon = self.landsPolygon {
                    _landsPolygon = try Helpers.blankWorldwidePolygon().intersection(with: landsPolygon)
                    _waterPolygon = try Helpers.blankWorldwidePolygon().difference(with: landsPolygon)
                }
            } catch { }
        }
    }

}
