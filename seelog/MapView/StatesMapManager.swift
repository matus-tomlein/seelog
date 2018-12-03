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
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var geoDB: GeoDatabase

    private var overlayManagers: [String: OverlayManager] = [:]
    private let fillColor = UIColor.red
    private let strokeColor = UIColor.white
    private let lineWidth: CGFloat = 1
    private let alpha: CGFloat = 0.25

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var stateKeysToAdd = Set<String>()
        if let visitedCountriesAndStates = year.countries(cumulative: cumulative) {
            for countryKey in visitedCountriesAndStates.keys {
                if let stateKeys = visitedCountriesAndStates[countryKey] {
                    for stateKey in stateKeys {
                        if overlayManagers[stateKey] == nil {
                            stateKeysToAdd.insert(stateKey)
                        }

                        polygonPropertyNamesToKeep.insert(stateKey)
                    }
                }
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

        for stateKey in stateKeysToAdd {
            self.createPolygon(forStateKey: stateKey, overlayVersion: overlayVersion)
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

    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? {
        return nil
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }

    private func createPolygon(forStateKey stateKey: String, overlayVersion: Int) {
        let overlayVersionManager = OverlayManager(mapView: mapView)

        if let stateInfo = geoDB.stateInfoFor(stateKey: stateKey) {
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
