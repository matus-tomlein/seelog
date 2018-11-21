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
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var geoDB: GeoDatabase
    var active = true

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        active = true

        DispatchQueue.global(qos: .background).async {
            var existingPolygonProperties = [PolygonProperties]()
            for overlay in self.mapView.overlays {
                if let polygon = overlay as? MKPolygon,
                    let polygonProperties = polygon.polygonProperties {
                    existingPolygonProperties.append(polygonProperties)
                }
            }

            var polygonPropertyNamesToKeep = Set<String>()
            var continentsToAdd: [ContinentInfo] = []
            if let continents = year.continentInfos(cumulative: cumulative, geoDB: self.geoDB) {
                for continent in continents {
                    let existing = existingPolygonProperties.filter({ $0.name == continent.name })
                    if existing.count == 0 {
                        continentsToAdd.append(continent)
                    }
                    polygonPropertyNamesToKeep.insert(continent.name)
                }
            }

            if !self.active { return }

            DispatchQueue.main.sync {
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

            for continent in continentsToAdd {
                if let geometry = continent.geometry {
                    let polygonProperties = PolygonProperties(name: continent.name,
                                                              zoomTypes: [.close, .medium, .far],
                                                              polygonType: .state,
                                                              alpha: 0.25)
                    self.mapViewDelegate.addGeometryToMap(geometry, polygonProperties: polygonProperties)
                }
            }
        }
    }

    func unload() {
        active = false
        mapView.removeOverlays(mapView.overlays)
    }

    func rendererFor(polygon: MKPolygon) -> MKOverlayRenderer? {
        let polygonView = PolygonRenderer(overlay: polygon)

        if let polygonProperties = polygon.polygonProperties {
            let color = UIColor.red
            polygonView.fillColor = color.withAlphaComponent(polygonProperties.alpha)

            polygonView.lineWidth = 1
            polygonView.strokeColor = UIColor.white
        }

        return polygonView
    }

    func updateForZoomType(_ zoomType: ZoomType) {}
    func viewChanged(visibleMapRect: MKMapRect) {}
    func longPress() {}
    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? { return nil }
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? { return nil }


}
