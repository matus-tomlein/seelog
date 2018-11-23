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

    private let fillColor = UIColor.red
    private let strokeColor = UIColor.white
    private let lineWidth: CGFloat = 1
    private let alpha: CGFloat = 0.25

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool, existingProperties: [MapOverlayProperties]) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var stateKeysToAdd = Set<String>()
        var countryKeysToAdd = Set<String>()
        if let visitedCountriesAndStates = year.countries(cumulative: cumulative) {
            for countryKey in visitedCountriesAndStates.keys {
                if currentTab == .states {
                    if let stateKeys = visitedCountriesAndStates[countryKey] {
                        for stateKey in stateKeys {
                            let existing = existingProperties.filter({ $0.name == stateKey })
                            if existing.count == 0 {
                                stateKeysToAdd.insert(stateKey)
                            }

                            polygonPropertyNamesToKeep.insert(stateKey)
                        }
                    }
                }

                if currentTab == .countries {
                    let existing = existingProperties.filter({ $0.name == countryKey })
                    if existing.count == 0 {
                        countryKeysToAdd.insert(countryKey)
                    }

                    polygonPropertyNamesToKeep.insert(countryKey)
                }
            }
        }

        for polygonProperties in existingProperties {
            if polygonPropertyNamesToKeep.contains(polygonProperties.name ?? "") {
                polygonProperties.overlayVersion = overlayVersion
            }
        }

        for stateKey in stateKeysToAdd {
            self.createPolygon(forStateKey: stateKey, overlayVersion: overlayVersion)
        }

        for countryKey in countryKeysToAdd {
            self.createPolygon(forCountryKey: countryKey, overlayVersion: overlayVersion)
        }
    }

    func unload() {
        mapView.removeOverlays(mapView.overlays)
    }

    func updateForZoomType(_ zoomType: ZoomType) {}
    func viewChanged(visibleMapRect: MKMapRect) {}

    func longPress() {}

    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? {
        return nil
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    private func createPolygon(forStateKey stateKey: String, overlayVersion: Int) {
        if let stateInfo = geoDB.stateInfoFor(stateKey: stateKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            if let geometry50m = stateInfo.geometry50m {
                let polygonProperties = MapOverlayProperties(name: stateKey,
                                                             zoomTypes: [.medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                mapViewDelegate.addGeometryToMap(geometry50m,
                                                 properties: polygonProperties)
            } else {
                closeZoomTypes.append(.medium)
                closeZoomTypes.append(.far)
            }
            if let geometry10m = stateInfo.geometry10m {
                let polygonProperties = MapOverlayProperties(name: stateKey,
                                                             zoomTypes: closeZoomTypes,
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                mapViewDelegate.addGeometryToMap(geometry10m,
                                                 properties: polygonProperties)
            }
        }
    }

    private func createPolygon(forCountryKey countryKey: String, overlayVersion: Int) {
        if let countryInfo = geoDB.countryInfoFor(countryKey: countryKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            var mediumZoomTypes: [ZoomType] = [.medium]

            if let geometry110m = countryInfo.geometry110m {
                let polygonProperties = MapOverlayProperties(name: countryKey,
                                                             zoomTypes: [.far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                mapViewDelegate.addGeometryToMap(geometry110m,
                                                 properties: polygonProperties)
            } else {
                mediumZoomTypes.append(.far)
            }
            if let geometry50m = countryInfo.geometry50m {
                let polygonProperties = MapOverlayProperties(name: countryKey,
                                                             zoomTypes: mediumZoomTypes,
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                mapViewDelegate.addGeometryToMap(geometry50m,
                                                 properties: polygonProperties)
            } else {
                for zoomType in mediumZoomTypes {
                    closeZoomTypes.append(zoomType)
                }
            }
            if let geometry10m = countryInfo.geometry10m {
                let polygonProperties = MapOverlayProperties(name: countryKey,
                                                             zoomTypes: closeZoomTypes,
                                                             overlayVersion: overlayVersion)
                polygonProperties.fillColor = fillColor
                polygonProperties.strokeColor = strokeColor
                polygonProperties.lineWidth = lineWidth
                polygonProperties.alpha = alpha
                mapViewDelegate.addGeometryToMap(geometry10m,
                                                 properties: polygonProperties)
            }
        }
    }

}
