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
    static var _landsPolygon: Geometry?
    static var _waterPolygon: Geometry?
    static var landsPolygon: Geometry? {
        get {
            if _landsPolygon == nil { initLandsAndWaterPolygons() }
            return _landsPolygon
        }
    }
    static var waterPolygon: Geometry? {
        get {
            if _waterPolygon == nil { initLandsAndWaterPolygons() }
            return _waterPolygon
        }
    }

    static func initLandsAndWaterPolygons() {
        if let landsPath = Bundle.main.path(forResource: "lands", ofType: "wkt") {
            do {
                _landsPolygon = try MultiPolygon(WKT: String(contentsOfFile: landsPath,
                                                             encoding: String.Encoding.utf8))
                if let landsPolygon = self.landsPolygon {
                    _landsPolygon = Helpers.blankWorldwidePolygon().intersection(landsPolygon)
                    _waterPolygon = Helpers.blankWorldwidePolygon().difference(landsPolygon)
                }
            } catch { }
        }
    }

}
