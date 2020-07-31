//
//  SeenGeometry.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Location: Hashable {
    let minX: Double
    let maxX: Double
    let minY: Double
    let maxY: Double
    var x: Double { return (self.minX + self.maxX) / 2 }
    var y: Double { return (self.minY + self.maxY) / 2 }
    
    init(geohash: String) {
        let decoded = Geohash.decode(hash: geohash)!
        let xs = [
            Helpers.longitudeToX(decoded.longitude.min),
            Helpers.longitudeToX(decoded.longitude.max),
        ].sorted()
        self.minX = xs.first!
        self.maxX = xs.last!
        let ys = [
            Helpers.latitudeToY(decoded.latitude.min),
            Helpers.latitudeToY(decoded.latitude.max),
        ].sorted()
        self.minY = ys.first!
        self.maxY = ys.last!
    }

    func toRectangle(boundsMinX: Double, boundsMaxX: Double, boundsMinY: Double, boundsMaxY: Double) -> (x: Double, y: Double, width: Double, height: Double) {
        let rectangleMinX = max(boundsMinX, self.minX)
        let rectangleMaxX = min(boundsMaxX, self.maxX)
        let rectangleMinY = max(boundsMinY, self.minY)
        let rectangleMaxY = min(boundsMaxY, self.maxY)
        let rect = (
            x: rectangleMinX,
            y: rectangleMinY,
            width: rectangleMaxX - rectangleMinX,
            height: rectangleMaxY - rectangleMinY
        )
        return rect
    }
}

struct SeenGeometry: Identifiable {
    var id: Int { get { return year ?? 0 } }
    var isTotal: Bool { get { return self.year == nil } }
    var year: Int?
    var geohashes: Set<String>
    var travelledDistance: Double
    var travelledDistanceRounded: Int { Int(travelledDistance.rounded()) }
    var higherLevelPositions: [Location]
    var positions: [Location]
    
    init(year: Int?, geohashes: Set<String>, travelledDistance: Double) {
        self.year = year
        self.geohashes = geohashes
        self.travelledDistance = travelledDistance
        self.positions = Array(geohashes).map { Location(geohash: $0) }
        self.higherLevelPositions = Array(Set(geohashes.map { geohash in String(geohash.prefix(3)) })).map { Location(geohash: $0) }
    }
}
