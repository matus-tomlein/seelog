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

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        mapView.mapType = .mutedStandard
        mapView.removeAnnotations(mapView.annotations)

        DispatchQueue.global(qos: .background).async {
            var existingPolygonProperties = [PolygonProperties]()
            for overlay in self.mapView.overlays {
                if let polygon = overlay as? MKPolygon,
                    let polygonProperties = polygon.polygonProperties {
                    existingPolygonProperties.append(polygonProperties)
                }
            }

            var polygonPropertyNamesToKeep = Set<String>()
            var stateKeysToAdd = Set<String>()
            var countryKeysToAdd = Set<String>()
            if let visitedCountriesAndStates = year.countries(cumulative: cumulative) {
                for countryKey in visitedCountriesAndStates.keys {
                    if currentTab == .states {
                        if let stateKeys = visitedCountriesAndStates[countryKey] {
                            for stateKey in stateKeys {
                                let existing = existingPolygonProperties.filter({ $0.name == stateKey })
                                if existing.count == 0 {
                                    stateKeysToAdd.insert(stateKey)
                                }

                                polygonPropertyNamesToKeep.insert(stateKey)
                            }
                        }
                    }

                    if currentTab == .countries {
                        let existing = existingPolygonProperties.filter({ $0.name == countryKey })
                        if existing.count == 0 {
                            countryKeysToAdd.insert(countryKey)
                        }

                        polygonPropertyNamesToKeep.insert(countryKey)
                    }
                }
            }

            DispatchQueue.main.async {
                for stateKey in stateKeysToAdd {
                    self.createPolygon(forStateKey: stateKey)
                }

                for countryKey in countryKeysToAdd {
                    self.createPolygon(forCountryKey: countryKey)
                }

                for overlay in self.mapView.overlays {
                    if let polygon = overlay as? MKPolygon,
                        let polygonProperties = polygon.polygonProperties {
                        if !polygonPropertyNamesToKeep.contains(polygonProperties.name) {
                            self.mapView.remove(overlay)
                        }
                    } else {
                        self.mapView.remove(overlay)
                    }
                }
            }
        }
    }

    func unload() {
    }

    func updateForZoomType(_ zoomType: ZoomType) {}
    func viewChanged(visibleMapRect: MKMapRect) {}

    func longPress() {}

    func rendererFor(polygon: MKPolygon) -> MKOverlayRenderer? {
        let polygonView = PolygonRenderer(overlay: polygon)

        if let polygonProperties = polygon.polygonProperties {
            let color = UIColor.red
            polygonView.fillColor = color.withAlphaComponent(polygonProperties.alpha)

            polygonView.lineWidth = 1
            polygonView.strokeColor = UIColor.white
            // polygonView.alpha = polygonProperties.zoomTypes.contains(currentZoomType) ? 1 : 0
        }

        return polygonView
    }

    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? {
        return nil
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    private func createPolygon(forStateKey stateKey: String) {
        if let stateInfo = geoDB.stateInfoFor(stateKey: stateKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            if let geometry50m = stateInfo.geometry50m {
                let polygonProperties = PolygonProperties(name: stateKey,
                                                          zoomTypes: [.medium, .far],
                                                          polygonType: .state,
                                                          alpha: 0.25)
                mapViewDelegate.addGeometryToMap(geometry50m, polygonProperties: polygonProperties)
            } else {
                closeZoomTypes.append(.medium)
                closeZoomTypes.append(.far)
            }
            if let geometry10m = stateInfo.geometry10m {
                let polygonProperties = PolygonProperties(name: stateKey,
                                                          zoomTypes: closeZoomTypes,
                                                          polygonType: .state,
                                                          alpha: 0.25)
                mapViewDelegate.addGeometryToMap(geometry10m, polygonProperties: polygonProperties)
            }
        }
    }

    private func createPolygon(forCountryKey countryKey: String) {
        if let countryInfo = geoDB.countryInfoFor(countryKey: countryKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            var mediumZoomTypes: [ZoomType] = [.medium]

            if let geometry110m = countryInfo.geometry110m {
                let polygonProperties = PolygonProperties(name: countryKey,
                                                          zoomTypes: [.far],
                                                          polygonType: .country,
                                                          alpha: 0.25)
                mapViewDelegate.addGeometryToMap(geometry110m, polygonProperties: polygonProperties)
            } else {
                mediumZoomTypes.append(.far)
            }
            if let geometry50m = countryInfo.geometry50m {
                let polygonProperties = PolygonProperties(name: countryKey,
                                                          zoomTypes: mediumZoomTypes,
                                                          polygonType: .country,
                                                          alpha: 0.25)
                mapViewDelegate.addGeometryToMap(geometry50m, polygonProperties: polygonProperties)
            } else {
                for zoomType in mediumZoomTypes {
                    closeZoomTypes.append(zoomType)
                }
            }
            if let geometry10m = countryInfo.geometry10m {
                let polygonProperties = PolygonProperties(name: countryKey,
                                                          zoomTypes: closeZoomTypes,
                                                          polygonType: .country,
                                                          alpha: 0.25)
                mapViewDelegate.addGeometryToMap(geometry10m, polygonProperties: polygonProperties)
            }
        }
    }

}
