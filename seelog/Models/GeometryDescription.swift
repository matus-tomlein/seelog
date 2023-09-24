//
//  GeometryDescription.swift
//  seelog
//
//  Created by Matus Tomlein on 07/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift
import MapKit

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
    
//    lazy var envelope: Polygon? = {
//        if let envelopeGeometry = try? geometry?.envelope().geometry {
//            if case let .polygon(envelope) = envelopeGeometry {
//                return envelope.exterior.points.map { p in
//                    Point(x: Helpers.longitudeToX(p.x), Helpers.latitudeToY(p.y))
//                }
//            }
//        }
//        return nil
//    }()
    
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
    
    var centroid: Point? {
        if let centroid = try? geometry?.centroid() {
            let (x, y) = Helpers.geolocationToXY(latitude: centroid.y, longitude: centroid.x)
            return Point(x: x, y: y)
        }
        return nil
    }
    
    var coordinateRegion: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: maxLatitude - minLatitude, longitudeDelta: maxLongitude - minLongitude)
        let center = CLLocationCoordinate2D(latitude: (maxLatitude - span.latitudeDelta / 2), longitude: maxLongitude - span.longitudeDelta / 2)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var boundingRect: Polygon? {
        guard let envelope = try? geometry?.minimumRotatedRectangle() else { return nil }
        switch envelope {
        case let .polygon(polygon):
            return try? Polygon(
                exterior: Polygon.LinearRing(
                    points: polygon.exterior.points.map { p in
                        Point(x: Helpers.longitudeToX(p.x), y: Helpers.latitudeToY(p.y))
                    }
                )
            )
        default:
            return nil
        }
    }
    
    func intersects(mapRegion: MKCoordinateRegion) -> Bool {
        guard let envelope = boundingRect else { return false }
        return Helpers.intersects(polygon: envelope, mapRegion: mapRegion)
    }
}
