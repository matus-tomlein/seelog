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

    var seenGeometry: SeenGeometry?
    var photoViewer: PhotoMapViewer?
    var overlayManager: OverlayManager?

    init(seenGeometry: SeenGeometry?, photoViewer: PhotoMapViewer?) {
        self.seenGeometry = seenGeometry
        self.photoViewer = photoViewer
    }

    func load(mapViewDelegate: MainMapViewDelegate) {
        mapViewDelegate.mapView.mapType = .mutedStandard
        DispatchQueue.main.sync {
            unload(mapViewDelegate: mapViewDelegate)
            if #available(iOS 13.0, *) {
                mapViewDelegate.mapView.overrideUserInterfaceStyle = .light
            }
        }
        let overlayManager = OverlayManager(mapView: mapViewDelegate.mapView)
        self.overlayManager = overlayManager

        let overlayVersion = GeometryOverlayCreator.overlayVersion

        let landProperties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                  overlayVersion: overlayVersion)
        landProperties.fillColor = UIColor(red: 43 / 255.0, green: 45 / 255.0, blue: 47 / 255.0, alpha: 1)

        let waterProperties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                   overlayVersion: overlayVersion)
        waterProperties.fillColor = UIColor(red: 49 / 255.0, green: 68 / 255.0, blue: 101 / 255.0, alpha: 1)

        if let seenGeometry = seenGeometry {
            if let land = Helpers.geometry(fromWKT: seenGeometry.landWKT),
                let water = Helpers.geometry(fromWKT: seenGeometry.waterWKT),
                let heatmap = Helpers.geometry(fromWKT: seenGeometry.processedWKT) {
                overlayManager.add(geometry: land, properties: landProperties)
                overlayManager.add(geometry: water, properties: waterProperties)

        //                self.mapView.centerCoordinate = self.mapView.centerCoordinate
                var boundary: Geometry? {
                    switch heatmap {
                    case let .polygon(polygon):
                        return try? polygon.boundary()
                    case let .multiPolygon(multiPolygon):
                        return try? multiPolygon.boundary()
                    default:
                        return nil
                    }
                }

                if let boundary = boundary, let bufferedHeatmap = try? heatmap.buffer(by: 0.4) {
                    let heatmapProperties = MapOverlayProperties(zoomTypes: [.far],
                                                                 overlayVersion: overlayVersion)
                    heatmapProperties.fillColor = UIColor.white
                    overlayManager.add(geometry: bufferedHeatmap, properties: heatmapProperties)


                    let boundaryProperties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                                  overlayVersion: overlayVersion)
                    boundaryProperties.strokeColor = UIColor.white
                    boundaryProperties.lineWidth = 2
                    overlayManager.add(geometry: boundary, properties: boundaryProperties)
                }
            }

//            self.photoViewer.load(model: model, year: year)
        } else {
            if let land = WorldPolygons.landsPolygon,
                let water = WorldPolygons.waterPolygon {
                overlayManager.add(geometry: land.geometry, properties: landProperties)
                overlayManager.add(geometry: water.geometry, properties: waterProperties)
            }
        }
    }

    func unload(mapViewDelegate: MainMapViewDelegate) {
//        photoViewer.unload()
        overlayManager?.unload()
        overlayManager = nil

        if #available(iOS 13.0, *) {
            mapViewDelegate.mapView.overrideUserInterfaceStyle = .unspecified
        }
    }

    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView? {
        return nil
    }

    func updateForZoomType(_ zoomType: ZoomType, mapViewDelegate: MainMapViewDelegate) {}

    func viewChanged(visibleMapRect: MKMapRect, mapViewDelegate: MainMapViewDelegate) {
//        photoViewer.viewChanged(visibleMapRect: visibleMapRect)
        overlayManager?.viewChanged(visibleMapRect: visibleMapRect)
    }

    var lastActiveLongPress: TimeInterval?
    func longPress(mapViewDelegate: MainMapViewDelegate) {
        if lastActiveLongPress == nil {
            setHeatmapPolygonTransparency(alpha: 0.5, mapViewDelegate: mapViewDelegate)
        }
        lastActiveLongPress = Date().timeIntervalSince1970
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.resetLongPress(mapViewDelegate: mapViewDelegate)
        }
    }

    func resetLongPress(mapViewDelegate: MainMapViewDelegate) {
        guard let lastActiveLongPress = self.lastActiveLongPress else { return }
        if Date().timeIntervalSince1970 - lastActiveLongPress >= 3 {
            setHeatmapPolygonTransparency(alpha: 1, mapViewDelegate: mapViewDelegate)
            self.lastActiveLongPress = nil
        }
    }

    private func setHeatmapPolygonTransparency(alpha: CGFloat, mapViewDelegate: MainMapViewDelegate) {
        for overlay in mapViewDelegate.mapView.overlays {
            if let polygon = overlay as? MapPolygon,
                let polygonProperties = polygon.properties {
                if polygonProperties.polygonType == .heatmapWater || polygonProperties.polygonType == .heatmapLand {
                    mapViewDelegate.mapView.renderer(for: overlay)?.alpha = alpha
                }
            }
        }
    }

}
