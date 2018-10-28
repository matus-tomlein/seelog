//
//  HeatmapSquare.swift
//  seelog
//
//  Created by Matus Tomlein on 09/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData
import GEOSwift

extension HeatmapSquare {
    static func all(context: NSManagedObjectContext) -> [HeatmapSquare]? {
        do {
            let request = NSFetchRequest<HeatmapSquare>(entityName: "HeatmapSquare")
            return try context.fetch(request)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return nil
    }

    static func allGeohashes(context: NSManagedObjectContext) -> Set<String> {
        var geohashes: Set<String> = []

        if let squares = all(context: context) {
            for square in squares {
                if let geohash = square.geohash {
                    geohashes.insert(geohash)
                }
            }
        }

        return geohashes
    }

    static func polygon(context: NSManagedObjectContext) -> Geometry? {
        if let p1 = Geometry.create("POLYGON((-180 -90, 0 -90, 0 0, -180 0, -180 -90))"),
            let p2 = Geometry.create("POLYGON((0 0, 180 0, 180 90, 0 90, 0 0))"),
            let p3 = Geometry.create("POLYGON((-180 0, 0 0, 0 90, -180 90, -180 0))"),
            let p4 = Geometry.create("POLYGON((0 -90, 180 -90, 180 0, 0 0, 0 -90))") {
            if let p12 = p1.union(p2),
                let p123 = p12.union(p3),
                var polygon = p123.union(p4) {
                if let heatmapSquares = HeatmapSquare.all(context: context) {

                    for square in heatmapSquares {
                        guard let geohash = square.geohash else { continue }
                        if let result = Geohash.decode(hash: geohash) {
                            if let squarePolygon = Geometry.create("POLYGON((\(result.longitude.min) \(result.latitude.min), \(result.longitude.max) \(result.latitude.min), \(result.longitude.max) \(result.latitude.max), \(result.longitude.min) \(result.latitude.max), \(result.longitude.min) \(result.latitude.min)))") {
                                if let newPolygon = polygon.difference(squarePolygon) {
                                    polygon = newPolygon
                                }
                            }
                        }
                    }
                }

                return polygon
            }
        }
        return nil
    }
}
