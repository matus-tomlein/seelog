//
//  GeometryOverlayCreator.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift
import Photos

class GeometryOverlayCreator {
    static var overlayVersion = 0

    static func addOverlayToMap(geometry: Geometry,
                                properties: MapOverlayProperties,
                                mapView: MKMapView) {
        if properties.overlayVersion < self.overlayVersion { return }

        switch geometry {
        case let ls as LineString:
            var coordinates = ls.points.map(CLLocationCoordinate2D.init)
            let mapPolyline = MapPolyline(coordinates: &coordinates,
                              count: coordinates.count)
            mapPolyline.properties = properties
            mapView.add(mapPolyline)

        case let polygon as Polygon:
            var exteriorRingCoordinates = polygon.exteriorRing.points.map(CLLocationCoordinate2D.init)
            let interiorRings = polygon.interiorRings.map {
                MKPolygonWithCoordinatesSequence($0.points)
            }
            let mapPolygon = MapPolygon(coordinates: &exteriorRingCoordinates,
                             count: exteriorRingCoordinates.count,
                             interiorPolygons: interiorRings)
            mapPolygon.properties = properties
            mapView.add(mapPolygon)

        case let gc as MultiLineString<LineString>:
            for geometry in gc.geometries {
                addOverlayToMap(geometry: geometry, properties: properties, mapView: mapView)
            }

        case let gc as MultiPolygon<Polygon>:
            for geometry in gc.geometries {
                addOverlayToMap(geometry: geometry, properties: properties, mapView: mapView)
            }

        case let gc as GeometryCollection<Geometry>:
            for geometry in gc.geometries {
                addOverlayToMap(geometry: geometry, properties: properties, mapView: mapView)
            }

        default:
            break
        }
    }

    static func addCircleToMap(center: CLLocationCoordinate2D,
                               radius: CLLocationDistance,
                               properties: MapOverlayProperties,
                               mapView: MKMapView) -> MapCircle? {
        if properties.overlayVersion < self.overlayVersion { return nil }

        let circle = MapCircle(center: center, radius: radius)
        circle.properties = properties
        mapView.add(circle)
        return circle
    }

    static func addImageToMap(image: UIImage,
                              assets: [PHAsset],
                              mapView: MKMapView,
                              location: CLLocationCoordinate2D,
                              overlayVersion: Int) -> ImageOverlay? {
        if overlayVersion < self.overlayVersion { return nil }

        let imageOverlay = ImageOverlay(image: image,
                                        assets: assets,
                                        coordinate: location,
                                        properties: MapOverlayProperties(overlayVersion))
        imageOverlay.addTo(mapView: mapView)
        return imageOverlay
    }

    static func removeOldOverlays(mapView: MKMapView) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        let overlaysToRemove = mapView.overlays.filter({ (($0 as? MapOverlay)?.getProperties()?.overlayVersion ?? 0) < overlayVersion })
        mapView.removeOverlays(overlaysToRemove)
    }

    private static func MKPolygonWithCoordinatesSequence(_ coordinates: CoordinatesCollection) -> MKPolygon {
        var coordinates = coordinates.map(CLLocationCoordinate2D.init)
        return MKPolygon(coordinates: &coordinates,
                         count: coordinates.count)

    }
}

extension CLLocationCoordinate2D {
    public init(_ coord: Coordinate) {
        self.init(latitude: coord.y, longitude: coord.x)
    }
}
