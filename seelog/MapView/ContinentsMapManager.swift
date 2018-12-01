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
    private var overlayManagers: [String: OverlayManager] = [:]

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var continentsToAdd: [ContinentInfo] = []
        if let continents = year.continentInfos(cumulative: cumulative, geoDB: self.geoDB) {
            for continent in continents {
                if overlayManagers[continent.name] == nil {
                    continentsToAdd.append(continent)
                }
                polygonPropertyNamesToKeep.insert(continent.name)
            }
        }

        for name in overlayManagers.keys {
            if polygonPropertyNamesToKeep.contains(name) {
                overlayManagers[name]?.set(overlayVersion: overlayVersion)
            } else {
                overlayManagers[name]?.unload()
                overlayManagers.removeValue(forKey: name)
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

                let manager = OverlayManager(mapView: mapView)
                manager.add(geometry: geometry, properties: polygonProperties)
                overlayManagers[continent.name] = manager
            }
        }
    }

    func unload() {
        for manager in overlayManagers.values { manager.unload() }
        overlayManagers = [:]
    }

    func updateForZoomType(_ zoomType: ZoomType) {}

    func viewChanged(visibleMapRect: MKMapRect) {
        for manager in overlayManagers.values {
            manager.viewChanged(visibleMapRect: visibleMapRect)
        }
    }

    func longPress() {}
    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? { return nil }
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? { return nil }


}
