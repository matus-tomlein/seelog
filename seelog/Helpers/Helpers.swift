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
import MapKit

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

    static func blankWorldwidePolygon() throws -> GeometryConvertible {
        let p1 = try Polygon(wkt: "POLYGON((-180 -90, 0 -90, 0 0, -180 0, -180 -90))")
        let p2 = try Polygon(wkt: "POLYGON((0 0, 180 0, 180 90, 0 90, 0 0))")
        let p3 = try Polygon(wkt: "POLYGON((-180 0, 0 0, 0 90, -180 90, -180 0))")
        let p4 = try Polygon(wkt: "POLYGON((0 -90, 180 -90, 180 0, 0 0, 0 -90))")
        let p12 = try p1.union(with: p2)
        let p123 = try p12.union(with: p3)
        return try p123.union(with: p4)
    }

    static func polygonFor(geohash: String) -> GeometryConvertible? {
        if let result = Geohash.decode(hash: geohash) {
            return try? Geometry(wkt: "POLYGON((\(result.longitude.min) \(result.latitude.min), \(result.longitude.max) \(result.latitude.min), \(result.longitude.max) \(result.latitude.max), \(result.longitude.min) \(result.latitude.max), \(result.longitude.min) \(result.latitude.min)))")
        }
        return nil
    }

    static func geometry(fromWKT wkt: String) -> Geometry? {
        return try? Geometry.init(wkt: wkt)
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
        switch heatmap {
        case let .multiPolygon(multipolygon):
            var convexPolygonUnion: Geometry?

            for polygon in multipolygon.polygons {
                if let convexPolygon = try? polygon.convexHull() {
                    if let union = convexPolygonUnion {
                        convexPolygonUnion = try? union.union(with: convexPolygon)
                    } else {
                        convexPolygonUnion = convexPolygon
                    }
                }
            }
            return convexPolygonUnion ?? heatmap
        default:
            return heatmap
        }
    }

    static func geohashesIn(mapRect: MKMapRect) -> Set<String> {
        let lowLeft = MKMapPoint(x: mapRect.minX, y: mapRect.minY).coordinate
        let topRight = MKMapPoint(x: mapRect.maxX, y: mapRect.maxY).coordinate
        var geohashes = Set<String>()

        guard let minLatitude = [lowLeft.latitude, topRight.latitude].min(),
            let maxLatitude = [lowLeft.latitude, topRight.latitude].max(),
            let minLongitude = [lowLeft.longitude, topRight.longitude].min(),
            let maxLongitude = [lowLeft.longitude, topRight.longitude].max() else { return geohashes }

        var latitude = minLatitude
        while latitude <= maxLatitude {
            var longitude = minLongitude
            while longitude <= maxLongitude {
                let geohash = Geohash.encode(latitude: latitude, longitude: longitude, precision: .twentyKilometers)
                geohashes.insert(geohash)
                latitude += (maxLatitude - minLatitude) / 10
                longitude += (maxLongitude - minLongitude) / 10
            }
        }

        return geohashes
    }

    static func formatDateRange(since: Date, until: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let fromString = formatter.string(from: since)
        let untilString = formatter.string(from: until)

        if fromString == untilString { return fromString }
        return fromString + " – " + untilString
    }

    static func datesBetween(startDate: Date, endDate: Date, addingDateComponents: DateComponents) -> [Date] {
        let calendar = Calendar.current

        let normalizedStartDate = calendar.startOfDay(for: startDate)
        let normalizedEndDate = calendar.startOfDay(for: endDate)

        var dates: [Date] = []
        var currentDate = normalizedStartDate

        while currentDate <= normalizedEndDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: addingDateComponents, to: currentDate)!
        }

        return dates
    }

    static func daysInRange(startDate: Date, endDate: Date) -> [Date] {
        var component = DateComponents()
        component.day = 1
        return datesBetween(startDate: startDate, endDate: endDate, addingDateComponents: component)
    }

    static func yearDay(date: Date) -> Int32? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        if let day = calendar.ordinality(of: .day, in: .year, for: date) {
            let dayPadded = String(format: "%03d", day)
            return Int32("\(year)\(dayPadded)")
        }
        return nil
    }

    static func year(date: Date) -> Int16 {
        return Int16(Calendar.current.component(.year, from: date))
    }

    static func month(date: Date) -> Int16 {
        return Int16(Calendar.current.component(.month, from: date))
    }

    static func geolocationToXY(latitude: Double, longitude: Double) -> (Double, Double) {
        (
            (180 + longitude) / 360,
            (90 - latitude) / 180
        )
    }
    
}
