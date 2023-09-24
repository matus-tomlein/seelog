//
//  SeenGeometry.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct Location: Hashable {
    var minX: Double { Helpers.longitudeToX(minXRaw) }
    var maxX: Double { Helpers.longitudeToX(maxXRaw) }
    var minY: Double { Helpers.latitudeToY(minYRaw) }
    var maxY: Double { Helpers.latitudeToY(maxYRaw) }
    let minXRaw: Double
    let maxXRaw: Double
    let minYRaw: Double
    let maxYRaw: Double
    var x: Double { return (self.minX + self.maxX) / 2 }
    var y: Double { return (self.minY + self.maxY) / 2 }
    var polygon: Polygon? {
        return try? Polygon(exterior: Polygon.LinearRing(points: [
            Point(x: minXRaw, y: minYRaw),
            Point(x: maxXRaw, y: minYRaw),
            Point(x: maxXRaw, y: maxYRaw),
            Point(x: minXRaw, y: maxYRaw),
            Point(x: minXRaw, y: minYRaw)
        ]))
    }
    
    init(geohash: String) {
        let decoded = Geohash.decode(hash: geohash)!
        minXRaw = decoded.longitude.min
        maxXRaw = decoded.longitude.max
        minYRaw = decoded.latitude.min
        maxYRaw = decoded.latitude.max
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
    
    var heatmap: [Polygon] {
        let polygons = geohashes.map({ Helpers.polygonFor(geohash: $0) }).filter({ $0 != nil }).map({ $0! })
        let heatmap = MultiPolygon(polygons: polygons)
        
        guard let buffered = try? heatmap.buffer(by: 0.05) else { return [] }
        
        let processedHeatmap = Helpers.convexHeatmap(heatmap: buffered)
        
        switch processedHeatmap {
        case let .multiPolygon(multipolygon):
            return multipolygon.polygons
            
        case let .polygon(polygon):
            return [polygon]
            
        default:
            return []
        }
    }
    
    func polygons(zoomType: ZoomType) -> [Polygon] {
        let positions = zoomType == .far ? higherLevelPositions : positions
        let polygons = positions.compactMap { $0.polygon }
        
        let heatmap = MultiPolygon(polygons: polygons)
        
        guard let buffered = try? heatmap.buffer(by: 0.0) else { return heatmap.polygons }
        
        let processedHeatmap = Helpers.convexHeatmap(heatmap: buffered)
        
        switch processedHeatmap {
        case let .multiPolygon(multipolygon):
            return multipolygon.polygons
            
        case let .polygon(polygon):
            return [polygon]
            
        default:
            return []
        }
    }
}
