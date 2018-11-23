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

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool, existingProperties: [MapOverlayProperties]) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        var polygonPropertyNamesToKeep = Set<String>()
        var timezonesToAdd: [TimezoneInfo] = []
        if let timezones = year.timezones(cumulative: cumulative, geoDB: self.geoDB) {
            for timezone in timezones {
                let existing = existingProperties.filter({ $0.name == timezone.name })
                if existing.count == 0 {
                    timezonesToAdd.append(timezone)
                }
                polygonPropertyNamesToKeep.insert(timezone.name)
            }
        }

        for polygonProperties in existingProperties {
            if polygonPropertyNamesToKeep.contains(polygonProperties.name ?? "") {
                polygonProperties.overlayVersion = overlayVersion
            }
        }

        for timezone in timezonesToAdd {
            if let geometry = timezone.geometry {
                let polygonProperties = MapOverlayProperties(name: timezone.name,
                                                             zoomTypes: [.close, .medium, .far],
                                                             overlayVersion: overlayVersion)
                polygonProperties.alpha = 0.25
                polygonProperties.fillColor = UIColor.red
                polygonProperties.strokeColor = UIColor.white
                polygonProperties.lineWidth = 1
                self.mapViewDelegate.addGeometryToMap(geometry,
                                                      properties: polygonProperties)
            }
        }
    }

    func unload() {
        mapView.removeOverlays(mapView.overlays)
    }

    func updateForZoomType(_ zoomType: ZoomType) {}
    func viewChanged(visibleMapRect: MKMapRect) {}
    func longPress() {}
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? { return nil }


}
