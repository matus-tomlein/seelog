//
//  CountriesMapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

class CountriesMapManager: MapManager {
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

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool, purchasedHistory: Bool) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var countryKeysToAdd = Set<String>()
        if !year.isLocked(purchasedHistory: purchasedHistory) {
            if let visitedCountriesAndStates = year.countries(cumulative: cumulative) {
                for countryKey in visitedCountriesAndStates.keys {
                    if overlayManagers[countryKey] == nil {
                        countryKeysToAdd.insert(countryKey)
                    }

                    polygonPropertyNamesToKeep.insert(countryKey)
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

        for countryKey in countryKeysToAdd {
            self.createPolygon(forCountryKey: countryKey, overlayVersion: overlayVersion)
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

    private func createPolygon(forCountryKey countryKey: String, overlayVersion: Int) {
        let overlayVersionManager = OverlayManager(mapView: mapView)

        if let countryInfo = geoDB.countryInfoFor(countryKey: countryKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            var mediumZoomTypes: [ZoomType] = [.medium]

            if let geometry110m = countryInfo.geometry110m {
                let polygonProperties = MapOverlayProperties(zoomTypes: [.far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                overlayVersionManager.add(geometry: geometry110m,
                                          properties: polygonProperties)
            } else {
                mediumZoomTypes.append(.far)
            }
            if let geometry50m = countryInfo.geometry50m {
                let polygonProperties = MapOverlayProperties(zoomTypes: mediumZoomTypes,
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                overlayVersionManager.add(geometry: geometry50m,
                                          properties: polygonProperties)
            } else {
                for zoomType in mediumZoomTypes {
                    closeZoomTypes.append(zoomType)
                }
            }
            if let geometry10m = countryInfo.geometry10m {
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

        overlayManagers[countryKey] = overlayVersionManager
    }

}
