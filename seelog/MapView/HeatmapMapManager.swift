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
    var overlayManager: OverlayManager

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, context: NSManagedObjectContext) {
        self.mapView = mapView
        self.overlayManager = OverlayManager(mapView: mapView)
        self.mapViewDelegate = mapViewDelegate

        photoViewer = PhotoMapViewer(mapView: mapView,
                                     mapViewDelegate: mapViewDelegate,
                                     context: context)
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        mapView.mapType = .mutedStandard
        DispatchQueue.main.sync { unload() }
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        if let waterWKT = year.waterWKT(cumulative: cumulative),
            let landWKT = year.landWKT(cumulative: cumulative),
            let land = Helpers.geometry(fromWKT: landWKT),
            let water = Helpers.geometry(fromWKT: waterWKT),
            let heatmapWKT = year.processedHeatmapWKT(cumulative: cumulative),
            let heatmap = Helpers.geometry(fromWKT: heatmapWKT),
            let boundary = heatmap.boundary(),
            let bufferedHeatmap = heatmap.buffer(width: 0.4) {

            let landProperties = MapOverlayProperties(name: year.name,
                                                      zoomTypes: [.close, .medium, .far],
                                                      overlayVersion: overlayVersion)
            landProperties.fillColor = UIColor(red: 43 / 255.0, green: 45 / 255.0, blue: 47 / 255.0, alpha: 1)
            overlayManager.add(geometry: land, properties: landProperties)


            let waterProperties = MapOverlayProperties(name: year.name,
                                                       zoomTypes: [.close, .medium, .far],
                                                       overlayVersion: overlayVersion)
            waterProperties.fillColor = UIColor(red: 49 / 255.0, green: 68 / 255.0, blue: 101 / 255.0, alpha: 1)
            overlayManager.add(geometry: water, properties: waterProperties)

//                self.mapView.centerCoordinate = self.mapView.centerCoordinate

            let heatmapProperties = MapOverlayProperties(name: year.name,
                                                         zoomTypes: [.far],
                                                         overlayVersion: overlayVersion)
            heatmapProperties.fillColor = UIColor.white
            overlayManager.add(geometry: bufferedHeatmap, properties: heatmapProperties)


            let boundaryProperties = MapOverlayProperties(name: year.name,
                                                          zoomTypes: [.close, .medium, .far],
                                                          overlayVersion: overlayVersion)
            boundaryProperties.strokeColor = UIColor.white
            boundaryProperties.lineWidth = 2
            overlayManager.add(geometry: boundary, properties: boundaryProperties)

        }

        self.photoViewer.load(year: year, cumulative: cumulative)
    }

    func unload() {
        photoViewer.unload()
        overlayManager.unload()
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }

    func updateForZoomType(_ zoomType: ZoomType) {}

    func viewChanged(visibleMapRect: MKMapRect) {
        photoViewer.viewChanged(visibleMapRect: visibleMapRect)
        overlayManager.viewChanged(visibleMapRect: visibleMapRect)
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
            if let polygon = overlay as? MapPolygon,
                let polygonProperties = polygon.properties {
                if polygonProperties.polygonType == .heatmapWater || polygonProperties.polygonType == .heatmapLand {
                    mapView.renderer(for: overlay)?.alpha = alpha
                }
            }
        }
    }

}
