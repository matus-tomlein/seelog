//
//  TimezoneMapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 12/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

class TimezoneMapManager: MapManager {
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
        var timezonesToAdd: [TimezoneInfo] = []
        if let timezones = year.timezones(cumulative: cumulative, geoDB: self.geoDB) {
            for timezone in timezones {
                if overlayManagers[timezone.name] == nil {
                    timezonesToAdd.append(timezone)
                }
                polygonPropertyNamesToKeep.insert(timezone.name)
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

        for timezone in timezonesToAdd {
            if let geometry = timezone.geometry {
                let polygonProperties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.alpha = 0.25
                polygonProperties.fillColor = UIColor.red
                polygonProperties.strokeColor = UIColor.white
                polygonProperties.lineWidth = 1

                let manager = OverlayManager(mapView: mapView)
                manager.add(geometry: geometry, properties: polygonProperties)
                overlayManagers[timezone.name] = manager
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
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? { return nil }


}
