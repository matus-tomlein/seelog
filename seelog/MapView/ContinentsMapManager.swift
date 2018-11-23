//
//  ContinentsMapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 12/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

class ContinentsMapManager: MapManager {
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var geoDB: GeoDatabase

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool, existingProperties: [MapOverlayProperties]) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var continentsToAdd: [ContinentInfo] = []
        if let continents = year.continentInfos(cumulative: cumulative, geoDB: self.geoDB) {
            for continent in continents {
                let existing = existingProperties.filter({ $0.name == continent.name })
                if existing.count == 0 {
                    continentsToAdd.append(continent)
                }
                polygonPropertyNamesToKeep.insert(continent.name)
            }
        }

        for polygonProperties in existingProperties {
            if polygonPropertyNamesToKeep.contains(polygonProperties.name ?? "") {
                polygonProperties.overlayVersion = overlayVersion
            }
        }

        for continent in continentsToAdd {
            if let geometry = continent.geometry {
                let polygonProperties = MapOverlayProperties(name: continent.name,
                                                             zoomTypes: [.close, .medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.alpha = 0.25
                polygonProperties.fillColor = UIColor.red
                polygonProperties.strokeColor = UIColor.white
                polygonProperties.lineWidth = 1
                self.mapViewDelegate.addGeometryToMap(geometry,
                                                      properties: polygonProperties)
            }
        }
    }

    func unload() {
        mapView.removeOverlays(mapView.overlays)
    }

    func updateForZoomType(_ zoomType: ZoomType) {}
    func viewChanged(visibleMapRect: MKMapRect) {}
    func longPress() {}
    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? { return nil }
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? { return nil }


}
