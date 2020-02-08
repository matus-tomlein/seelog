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
import GEOSwiftMapKit

extension Point {
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
        if let envelopeGeometry = try? geometry.envelope().geometry {
            if case let .polygon(envelope) = envelopeGeometry {
                self.envelope = envelope
            }
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
        guard let envelope = self.envelope else { return false }

        let lowLeft = Point(MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate)
        let lowRight = Point(MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.minY).coordinate)
        let topRight = Point(MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate)
        let topLeft = Point(MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.maxY).coordinate)

        do {
            if lowLeft.x > lowRight.x {
                let lowRight1 = Point(x: 180, y: lowRight.y)
                let lowRight2 = Point(x: -180, y: lowRight.y)
                let topRight1 = Point(x: 180, y: topRight.y)
                let topRight2 = Point(x: -180, y: topRight.y)

                let ring1 = try Polygon.LinearRing(points: [lowLeft, lowRight1, topRight1, topLeft, lowLeft])
                let ring2 = try Polygon.LinearRing(points: [lowLeft, lowRight2, topRight2, topLeft, lowLeft])
                let viewPolygon1 = Polygon(exterior: ring1)
                let viewPolygon2 = Polygon(exterior: ring2)

                return try envelope.intersects(viewPolygon1) || envelope.intersects(viewPolygon2)
            } else {
                let ring = try Polygon.LinearRing(points: [lowLeft, lowRight, topRight, topLeft, lowLeft])
                let viewPolygon = Polygon(exterior: ring)

                return try envelope.intersects(viewPolygon)
            }
        } catch {}

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
            if let o = overlay as? MKOverlay { mapView?.removeOverlay(o) }
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
        if Thread.isMainThread {
            for overlay in overlays { overlay.remove() }
        } else {
            DispatchQueue.main.sync {
                for overlay in self.overlays { overlay.remove() }
            }
        }
        overlays = []
    }

    func set(overlayVersion: Int) {
        for overlay in overlays { overlay.overlayVersion = overlayVersion }
    }
}
