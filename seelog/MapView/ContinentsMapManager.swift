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
    private var continents: [Continent]
    private var overlayManagers: [String: OverlayManager] = [:]

    init(continents: [Continent]) {
        self.continents = continents
    }

    func load(mapViewDelegate: MainMapViewDelegate) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var continentsToAdd: [Continent] = []
        for continent in continents {
            if overlayManagers[continent.continentInfo.name] == nil {
                continentsToAdd.append(continent)
            }
            polygonPropertyNamesToKeep.insert(continent.continentInfo.name)
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
            if let geometry = continent.continentInfo.geometry {
                let polygonProperties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.alpha = 0.25
                polygonProperties.fillColor = UIColor.red
                polygonProperties.strokeColor = UIColor.white
                polygonProperties.lineWidth = 1

                let manager = OverlayManager(mapView: mapViewDelegate.mapView)
                manager.add(geometry: geometry, properties: polygonProperties)
                overlayManagers[continent.continentInfo.name] = manager
            }
        }
    }

    func unload(mapViewDelegate: MainMapViewDelegate) {
        for manager in overlayManagers.values { manager.unload() }
        overlayManagers = [:]
    }

    func updateForZoomType(_ zoomType: ZoomType, mapViewDelegate: MainMapViewDelegate) {}

    func viewChanged(visibleMapRect: MKMapRect, mapViewDelegate: MainMapViewDelegate) {
        for manager in overlayManagers.values {
            manager.viewChanged(visibleMapRect: visibleMapRect)
        }
    }

    func longPress(mapViewDelegate: MainMapViewDelegate) {}
    func nonPolygonRendererFor(overlay: MKOverlay, mapViewDelegate: MainMapViewDelegate) -> MKOverlayRenderer? { return nil }
    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView? { return nil }


}
