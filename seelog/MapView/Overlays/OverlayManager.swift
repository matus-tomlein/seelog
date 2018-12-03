//
//  PolygonOverlayManager.swift
//  seelog
//
//  Created by Matus Tomlein on 01/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

extension Coordinate {
    public init(_ coord: CLLocationCoordinate2D) {
        self.init(x: coord.longitude, y: coord.latitude)
    }
}

fileprivate class MapOverlayState {
    private var geometry: Geometry
    var properties: MapOverlayProperties
    private var overlays: [MapOverlay] = []
    private var envelope: Polygon?
    private weak var mapView: MKMapView?

    var shown: Bool { get { return overlays.count > 0 }}

    var overlayVersion: Int {
        get { return properties.overlayVersion }
        set { properties.overlayVersion = newValue }
    }

    init(geometry: Geometry, properties: MapOverlayProperties, mapView: MKMapView) {
        self.geometry = geometry
        if let envelope = geometry.envelope() as? Polygon {
            self.envelope = envelope
        }
        self.properties = properties
        self.mapView = mapView
    }

    func viewChanged(visibleMapRect: MKMapRect) {
        if intersects(visibleMapRect: visibleMapRect) {
            let zoomType = zoomTypeFor(visibleMapRect: visibleMapRect)
            if properties.zoomTypes?.contains(zoomType) ?? false {
                show()
            } else {
                remove()
            }
        }
    }

    private func intersects(visibleMapRect: MKMapRect) -> Bool {
        let lowLeft = Coordinate(MKCoordinateForMapPoint(MKMapPointMake(visibleMapRect.minX, visibleMapRect.minY)))
        let lowRight = Coordinate(MKCoordinateForMapPoint(MKMapPointMake(visibleMapRect.maxX, visibleMapRect.minY)))
        let topRight = Coordinate(MKCoordinateForMapPoint(MKMapPointMake(visibleMapRect.maxX, visibleMapRect.maxY)))
        let topLeft = Coordinate(MKCoordinateForMapPoint(MKMapPointMake(visibleMapRect.minX, visibleMapRect.maxY)))

        if let ring = LinearRing(points: [lowLeft, lowRight, topRight, topLeft, lowLeft]),
            let viewPolygon = Polygon(shell: ring, holes: nil),
            let envelope = self.envelope {
            return envelope.intersects(viewPolygon)
        }

        return false
    }

    private func zoomTypeFor(visibleMapRect: MKMapRect) -> ZoomType {
        let width = visibleMapRect.width

        if width > 35000000 { return ZoomType.far }
        if width > 6000000 { return ZoomType.medium }
        return ZoomType.close
    }

    private func show() {
        if shown { return }
        guard let mapView = self.mapView else { return }

        self.overlays = GeometryOverlayCreator.addOverlayToMap(geometry: geometry, properties: properties, mapView: mapView)
    }

    func remove() {
        if !shown { return }
        let currentOverlays = self.overlays
        self.overlays = []

        for overlay in currentOverlays {
            if let o = overlay as? MKOverlay { mapView?.remove(o) }
        }
    }
}

class OverlayManager {
    private var overlays = [MapOverlayState]()
    private weak var mapView: MKMapView?

    var allProperties: [MapOverlayProperties] {
        get {
            return overlays.map({ $0.properties })
        }
    }

    init(mapView: MKMapView) {
        self.mapView = mapView
    }

    func add(geometry: Geometry, properties: MapOverlayProperties) {
        guard let mapView = self.mapView else { return }
        overlays.append(MapOverlayState(geometry: geometry, properties: properties, mapView: mapView))
    }

    func viewChanged(visibleMapRect: MKMapRect) {
        for overlay in overlays {
            overlay.viewChanged(visibleMapRect: visibleMapRect)
        }
    }

    func unload() {
        for overlay in overlays { overlay.remove() }
        overlays = []
    }

    func set(overlayVersion: Int) {
        for overlay in overlays { overlay.overlayVersion = overlayVersion }
    }
}