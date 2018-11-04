//
//  HeatmapMapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

class HeatmapMapManager: MapManager {

    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate

    static var _landsPolygon: Geometry?
    static var _waterPolygon: Geometry?
    static var landsPolygon: Geometry? {
        get {
            if _landsPolygon == nil { initLandsAndWaterPolygons() }
            return _landsPolygon
        }
    }
    static var waterPolygon: Geometry? {
        get {
            if _waterPolygon == nil { initLandsAndWaterPolygons() }
            return _waterPolygon
        }
    }

    static func initLandsAndWaterPolygons() {
        if let landsPath = Bundle.main.path(forResource: "lands", ofType: "wkt") {
            do {
                _landsPolygon = try MultiPolygon(WKT: String(contentsOfFile: landsPath,
                                                            encoding: String.Encoding.utf8))
                if let landsPolygon = self.landsPolygon {
                    _landsPolygon = Helpers.blankWorldwidePolygon().intersection(landsPolygon)
                    _waterPolygon = Helpers.blankWorldwidePolygon().difference(landsPolygon)
                }
            } catch { }
        }
    }

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
    }

    func load(year: Year, cumulative: Bool) {
        mapView.mapType = .hybrid
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        if let wkt = year.heatmapWKT(cumulative: cumulative),
            let heatmap = Helpers.geometry(fromWKT: wkt) {
            if let land = HeatmapMapManager.landsPolygon?.difference(heatmap),
                let water = HeatmapMapManager.waterPolygon?.difference(heatmap) {
                mapViewDelegate.addGeometryToMap(land, polygonProperties: PolygonProperties(name: year.name,
                                                                            zoomTypes: [.close, .medium, .far],
                                                                            polygonType: .heatmapLand,
                                                                            alpha: 1))
                mapViewDelegate.addGeometryToMap(water, polygonProperties: PolygonProperties(name: year.name,
                                                                             zoomTypes: [.close, .medium, .far],
                                                                             polygonType: .heatmap,
                                                                             alpha: 1))

                if let boundaries = heatmap.boundary()?.mapShape() as? MKShapesCollection {
                    for boundary in boundaries.shapes {
                        if let polyline = boundary as? MKPolyline {
                            mapView.add(polyline)
                        }
                    }
                }
            }
        }
    }

    func rendererFor(polygon: MKPolygon) -> MKOverlayRenderer? {
        let polygonView = PolygonRenderer(overlay: polygon)

        if let polygonProperties = polygon.polygonProperties {
             // TODO: reuse polygon renderer?
            let color = polygonProperties.polygonType == .heatmapLand ?
                UIColor(red: 250 / 255.0, green: 245 / 255.0, blue: 238 / 255.0, alpha: polygonProperties.alpha) : // land
                UIColor(red: 167 / 255.0, green: 225 / 255.0, blue: 244 / 255.0, alpha: polygonProperties.alpha) // water
            polygonView.fillColor = color
        }

        return polygonView
    }

    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 1
        renderer.strokeColor = UIColor.red
        return renderer
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }

    func updateForZoomType(_ zoomType: ZoomType) {}

    var lastActiveLongPress: TimeInterval?
    func longPress() {
        if lastActiveLongPress == nil {
            setHeatmapPolygonTransparency(alpha: 0.5)
        }
        lastActiveLongPress = Date().timeIntervalSince1970
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.resetLongPress()
        }
    }

    func resetLongPress() {
        guard let lastActiveLongPress = self.lastActiveLongPress else { return }
        if Date().timeIntervalSince1970 - lastActiveLongPress >= 3 {
            setHeatmapPolygonTransparency(alpha: 1)
            self.lastActiveLongPress = nil
        }
    }

    private func setHeatmapPolygonTransparency(alpha: CGFloat) {
        for overlay in mapView.overlays {
            if let polygon = overlay as? MKPolygon,
                let polygonProperties = polygon.polygonProperties {
                if polygonProperties.polygonType == .heatmap || polygonProperties.polygonType == .heatmapLand {
                    mapView.renderer(for: overlay)?.alpha = alpha
                }
            }
        }
    }

}
