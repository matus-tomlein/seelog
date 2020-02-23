//
//  StatesMapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 30/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

class StatesMapManager: MapManager {
    
    private var overlayManagers: [String: OverlayManager] = [:]
    private let fillColor = UIColor.red
    private let strokeColor = UIColor.white
    private let lineWidth: CGFloat = 1
    private let alpha: CGFloat = 0.25
    private let states: [Region]

    init(states: [Region]) {
        self.states = states
    }

    func load(mapViewDelegate: MainMapViewDelegate) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var stateKeysToAdd = Set<String>()
        for state in states {
            if overlayManagers[state.stateInfo.stateKey] == nil {
                stateKeysToAdd.insert(state.stateInfo.stateKey)
            }

            polygonPropertyNamesToKeep.insert(state.stateInfo.stateKey)
        }

        for name in overlayManagers.keys {
            if polygonPropertyNamesToKeep.contains(name) {
                overlayManagers[name]?.set(overlayVersion: overlayVersion)
            } else {
                overlayManagers[name]?.unload()
                overlayManagers.removeValue(forKey: name)
            }
        }

        for stateKey in stateKeysToAdd {
            self.createPolygon(forStateKey: stateKey, overlayVersion: overlayVersion, mapViewDelegate: mapViewDelegate)
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

    func nonPolygonRendererFor(overlay: MKOverlay, mapViewDelegate: MainMapViewDelegate) -> MKOverlayRenderer? {
        return nil
    }

    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView? {
        return nil
    }

    private func createPolygon(forStateKey stateKey: String, overlayVersion: Int, mapViewDelegate: MainMapViewDelegate) {
        let overlayVersionManager = OverlayManager(mapView: mapViewDelegate.mapView)

        if let stateInfo = states.first(where: { $0.stateInfo.stateKey == stateKey })?.stateInfo {
            var closeZoomTypes: [ZoomType] = [.close]
            if let geometry50m = stateInfo.geometry50m {
                let polygonProperties = MapOverlayProperties(zoomTypes: [.medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                overlayVersionManager.add(geometry: geometry50m,
                                          properties: polygonProperties)
            } else {
                closeZoomTypes.append(.medium)
                closeZoomTypes.append(.far)
            }
            if let geometry10m = stateInfo.geometry10m {
                let polygonProperties = MapOverlayProperties(zoomTypes: closeZoomTypes,
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                overlayVersionManager.add(geometry: geometry10m,
                                          properties: polygonProperties)
            }
        }

        overlayManagers[stateKey] = overlayVersionManager
    }
}
