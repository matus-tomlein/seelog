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
    private var overlayManagers: [String: OverlayManager] = [:]

    private let countries: [Country]
    private let fillColor = UIColor.red
    private let strokeColor = UIColor.white
    private let lineWidth: CGFloat = 1
    private let alpha: CGFloat = 0.25

    init(countries: [Country]) {
        self.countries = countries
    }

    func load(mapViewDelegate: MainMapViewDelegate) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var countryKeysToAdd = Set<String>()
        for country in countries {
            if overlayManagers[country.countryInfo.countryKey] == nil {
                countryKeysToAdd.insert(country.countryInfo.countryKey)
            }

            polygonPropertyNamesToKeep.insert(country.countryInfo.countryKey)
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
            if let country = countries.first(where: { $0.countryInfo.countryKey == countryKey }) {
                self.createPolygon(countryInfo: country.countryInfo, overlayVersion: overlayVersion, mapViewDelegate: mapViewDelegate)
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

    func nonPolygonRendererFor(overlay: MKOverlay, mapViewDelegate: MainMapViewDelegate) -> MKOverlayRenderer? {
        return nil
    }

    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView? {
        return nil
    }

    private func createPolygon(countryInfo: CountryInfo, overlayVersion: Int, mapViewDelegate: MainMapViewDelegate) {
        let overlayVersionManager = OverlayManager(mapView: mapViewDelegate.mapView)
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

        overlayManagers[countryInfo.countryKey] = overlayVersionManager
    }

}
