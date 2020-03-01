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
    var timezones: [Timezone]
    private var overlayManagers: [Int32: OverlayManager] = [:]

    init(timezones: [Timezone]) {
        self.timezones = timezones
    }

    func load(mapViewDelegate: MainMapViewDelegate) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<Int32>()
        var timezonesToAdd: [Timezone] = []
        for timezone in timezones {
            if overlayManagers[timezone.id] == nil {
                timezonesToAdd.append(timezone)
            }
            polygonPropertyNamesToKeep.insert(timezone.id)
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
            if let geometry = timezone.timezoneInfo.geometry {
                let polygonProperties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.alpha = 0.25
                polygonProperties.fillColor = UIColor.red
                polygonProperties.strokeColor = UIColor.white
                polygonProperties.lineWidth = 1

                let manager = OverlayManager(mapView: mapViewDelegate.mapView)
                manager.add(geometry: geometry, properties: polygonProperties)
                overlayManagers[timezone.id] = manager
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
    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView? { return nil }


}
