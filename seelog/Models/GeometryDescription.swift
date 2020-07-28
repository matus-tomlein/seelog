//
//  GeometryDescription.swift
//  seelog
//
//  Created by Matus Tomlein on 07/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct GeometryDescription {
    var geometry: Geometry?
    var minLatitude: Double
    var minLongitude: Double
    var maxLatitude: Double
    var maxLongitude: Double
    
    var minX: Double { Helpers.longitudeToX(minLongitude) }
    var minY: Double { Helpers.latitudeToY(maxLatitude) }
    var maxX: Double { Helpers.longitudeToX(maxLongitude) }
    var maxY: Double { Helpers.latitudeToY(minLatitude) }
    
    var polygons: [Polygon] {
        var polygons: [Polygon] = []
        if let geometry = geometry {
            switch geometry {
            case let .multiPolygon(p):
                polygons = p.polygons
                
            case let .polygon(p):
                polygons = [p]

            default:
                polygons = []
            }
        }
        return polygons
    }

    var polygonPoints: [[(x: Double, y: Double)]] {
        return polygons.map { polygon in
            polygon.exterior.points.map {
                let (x, y) = Helpers.geolocationToXY(latitude: $0.y, longitude: $0.x)
                return (x: x, y: y)
            }
        }
    }
}
