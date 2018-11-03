//
//  Helpers.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift
import CoreLocation

class Helpers {
    static func seasonForDate(_ date: Date) -> String {
//        0: 1 December     28 February
//        1: 1 March    31 May
//        2: 1 June    31 August
//        3: 1 September    30 November
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        var season = 0
        if month >= 12 {
            season = 0
            year += 1
        } else if month <= 2 {
            season = 0
        } else if month >= 3 && month <= 5 {
            season = 1
        } else if month >= 6 && month <= 8 {
            season = 2
        } else if month >= 9 && month <= 11 {
            season = 3
        }

        return seasonKey(year: year, season: season)
    }

    static func monthForDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        return monthKey(year: year, month: month)
    }

    static func yearForDate(_ date: Date) -> Int32 {
        let calendar = Calendar.current
        return Int32(calendar.component(.year, from: date))
    }

    static func monthKey(year: Int, month: Int) -> String {
        return String(year) + "-" + String(format: "%02d", month)
    }

    static func seasonKey(year: Int, season: Int) -> String {
        return String(year) + "-" + String(season)
    }

    static func yearsSince(_ since: Int32) -> [Int32] {
        let until = Int32(Calendar.current.component(.year, from: Date()))
        return Array(since...until)
    }

    static func monthsSince(_ since: String) -> [String] {
        let calendar = Calendar.current
        let until = Date()
        let untilYear = calendar.component(.year, from: until)
        let untilMonth = calendar.component(.month, from: until)

        let sinceYear = Int(since.split(separator: "-")[0]) ?? untilYear
        let sinceMonth = Int(since.split(separator: "-")[1]) ?? untilMonth

        var months: [String] = []
        for year in sinceYear...untilYear {
            let sinceMonthThisYear = year == sinceYear ? sinceMonth : 1
            let untilMonthThisYear = year == untilYear ? untilMonth : 12

            for month in sinceMonthThisYear...untilMonthThisYear {
                months.append(monthKey(year: year, month: month))
            }
        }
        return months
    }

    static func seasonsSince(_ since: String) -> [String] {
        let calendar = Calendar.current
        let untilSeason = seasonForDate(Date())
        let untilYear = Int(untilSeason.split(separator: "-")[0]) ?? calendar.component(.year, from: Date())
        let untilSeasonIndex = Int(untilSeason.split(separator: "-")[1]) ?? 0

        let sinceYear = Int(since.split(separator: "-")[0]) ?? untilYear
        let sinceSeasonIndex = Int(since.split(separator: "-")[1]) ?? untilSeasonIndex

        var seasons: [String] = []
        for year in sinceYear...untilYear {
            let sinceSeasonThisYear = year == sinceYear ? sinceSeasonIndex : 0
            let untilSeasonThisYear = year == untilYear ? untilSeasonIndex : 3

            for seasonIndex in sinceSeasonThisYear...untilSeasonThisYear {
                seasons.append(seasonKey(year: year, season: seasonIndex))
            }
        }

        return seasons
    }

    static func combineIntoUniqueList(_ l1: [String], _ l2: [String]) -> [String] {
        var notInL1: [String] = []
        for item in l2 {
            if !l1.contains(item) { notInL1.append(item) }
        }
        return l1 + notInL1
    }

    static func combineIntoUniqueList(_ l1: [Int64], _ l2: [Int64]) -> [Int64] {
        var notInL1: [Int64] = []
        for item in l2 {
            if !l1.contains(item) { notInL1.append(item) }
        }
        return l1 + notInL1
    }

    static func flag(country: String) -> String {
        if let countryCode = CountryCodeMappings.countryCodes[country] {
            let base = 127397
            var usv = String.UnicodeScalarView()
            for i in countryCode.utf16 {
                if let scalar = UnicodeScalar(base + Int(i)) {
                    usv.append(scalar)
                }
            }
            return String(usv)
        } else {
            return country
        }
    }

    static func blankWorldwidePolygon() -> Geometry {
        let p1 = Geometry.create("POLYGON((-180 -90, 0 -90, 0 0, -180 0, -180 -90))")!
        let p2 = Geometry.create("POLYGON((0 0, 180 0, 180 90, 0 90, 0 0))")!
        let p3 = Geometry.create("POLYGON((-180 0, 0 0, 0 90, -180 90, -180 0))")!
        let p4 = Geometry.create("POLYGON((0 -90, 180 -90, 180 0, 0 0, 0 -90))")!
        let p12 = p1.union(p2)!
        let p123 = p12.union(p3)!
        return p123.union(p4)!
    }

    static func polygonFor(geohash: String) -> Geometry? {
        if let result = Geohash.decode(hash: geohash) {
            return Geometry.create("POLYGON((\(result.longitude.min) \(result.latitude.min), \(result.longitude.max) \(result.latitude.min), \(result.longitude.max) \(result.latitude.max), \(result.longitude.min) \(result.latitude.max), \(result.longitude.min) \(result.latitude.min)))")
        }
        return nil
    }

    static func geometry(fromWKT wkt: String) -> Geometry? {
        if let polygon = MultiPolygon(WKT: wkt) {
            return polygon
        } else if let polygon = Polygon(WKT: wkt) {
            return polygon
        }
        return nil
    }

    static func areaOf(geohash: String) -> Double {
        if let decoded = Geohash.decode(hash: geohash) {
            let a0 = CLLocation(latitude: decoded.latitude.min, longitude: decoded.longitude.min)
            let a1 = CLLocation(latitude: decoded.latitude.max, longitude: decoded.longitude.min)
            let width = a0.distance(from: a1) / 1000

            let a2 = CLLocation(latitude: decoded.latitude.min, longitude: decoded.longitude.max)
            let height = a0.distance(from: a2) / 1000

            return width * height
        }
        return 0
    }

    static func convexHeatmap(heatmap: Geometry) -> Geometry {
        if let multipolygon = heatmap as? MultiPolygon {
            var convexPolygonUnion: Geometry?
            for polygon in multipolygon.geometries {
                if let convexPolygon = polygon.convexHull() {
                    if let union = convexPolygonUnion {
                        convexPolygonUnion = union.union(convexPolygon)
                    } else {
                        convexPolygonUnion = convexPolygon
                    }
                }
            }
            return convexPolygonUnion ?? heatmap
//            if convexPolygons.count > 0 {
//                if let result = MultiPolygon(geometries: convexPolygons) { return result }
//            }
        }

        return heatmap
    }
}
