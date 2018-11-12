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
import CoreData

class HeatmapMapManager: MapManager {

    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var photoViewer: PhotoMapViewer
    var active = true

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

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, context: NSManagedObjectContext) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate

        photoViewer = PhotoMapViewer(mapView: mapView,
                                     mapViewDelegate: mapViewDelegate,
                                     context: context)
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        mapView.mapType = .mutedStandard
        unload()
        active = true

        DispatchQueue.global(qos: .background).async {
            if let waterWKT = year.waterWKT(cumulative: cumulative),
                let landWKT = year.landWKT(cumulative: cumulative),
                let land = Helpers.geometry(fromWKT: landWKT),
                let water = Helpers.geometry(fromWKT: waterWKT),
                let heatmapWKT = year.processedHeatmapWKT(cumulative: cumulative),
                let heatmap = Helpers.geometry(fromWKT: heatmapWKT),
                let boundaries = heatmap.boundary()?.mapShape() as? MKShapesCollection,
                let bufferedHeatmap = heatmap.buffer(width: 0.4) {
                DispatchQueue.main.async {
                    if !self.active { return }
                    self.mapViewDelegate.addGeometryToMap(land, polygonProperties: PolygonProperties(name: year.name,
                                                                                zoomTypes: [.close, .medium, .far],
                                                                                polygonType: .heatmapLand,
                                                                                alpha: 1))
                    self.mapViewDelegate.addGeometryToMap(water, polygonProperties: PolygonProperties(name: year.name,
                                                                                 zoomTypes: [.close, .medium, .far],
                                                                                 polygonType: .heatmapWater,
                                                                                 alpha: 1))

                    self.mapView.centerCoordinate = self.mapView.centerCoordinate

                    for boundary in boundaries.shapes {
                        if let polyline = boundary as? MKPolyline {
                            self.mapView.add(polyline)
                        }
                    }

                    self.mapViewDelegate.addGeometryToMap(bufferedHeatmap, polygonProperties: PolygonProperties(name: year.name + "-buffered",
                                                                                                                zoomTypes: [.far],
                                                                                                                polygonType: .heatmap,
                                                                                                                alpha: 1))
                }
            }
        }

        self.photoViewer.load(year: year, cumulative: cumulative)
    }

    func unload() {
        active = false
        photoViewer.unload()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }

    func rendererFor(polygon: MKPolygon) -> MKOverlayRenderer? {
        let polygonView = PolygonRenderer(overlay: polygon)

        if let polygonProperties = polygon.polygonProperties {
             // TODO: reuse polygon renderer?
            switch polygonProperties.polygonType {
            case .heatmapLand:
                polygonView.fillColor = UIColor(red: 43 / 255.0, green: 45 / 255.0, blue: 47 / 255.0, alpha: polygonProperties.alpha)

            case .heatmapWater:
                polygonView.fillColor = UIColor(red: 49 / 255.0, green: 68 / 255.0, blue: 101 / 255.0, alpha: polygonProperties.alpha)

            default:
                polygonView.fillColor = UIColor.white
            }
        }

        return polygonView
    }

    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? {
        if overlay is ImageOverlay {
            return ImageOverlayRenderer(overlay: overlay)
        }
        if let imageBorder = overlay as? ImageBorderPolyline {
            let renderer = MKPolylineRenderer(overlay: imageBorder)
            renderer.lineWidth = 3
            renderer.strokeColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            return renderer
        } else if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(overlay: circle)
            renderer.lineWidth = 3
            renderer.strokeColor = UIColor.red
            return renderer
        } else {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 1
            renderer.strokeColor = UIColor.white
            return renderer
        }
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }

    func updateForZoomType(_ zoomType: ZoomType) {}

    func viewChanged(visibleMapRect: MKMapRect) {
        photoViewer.viewChanged(visibleMapRect: visibleMapRect)
    }

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
                if polygonProperties.polygonType == .heatmapWater || polygonProperties.polygonType == .heatmapLand {
                    mapView.renderer(for: overlay)?.alpha = alpha
                }
            }
        }
    }

}
