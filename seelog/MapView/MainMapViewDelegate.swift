//
//  MainMapViewDelegate.swift
//  seelog
//
//  Created by Matus Tomlein on 20/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit
import MapKit
import GEOSwift
import CoreData

class MainMapViewDelegate: NSObject, MKMapViewDelegate {
    var mapView: MKMapView
    var mapManager: MapManager?
    private weak var reportViewController: ReportViewController?

    init(mapView: MKMapView, reportViewController: ReportViewController) {
        self.mapView = mapView
        self.reportViewController = reportViewController
        super.init()

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(recognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        mapView.addGestureRecognizer(tapRecognizer)

        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
    }

    var currentZoomType: ZoomType = .close {
        didSet {
            guard oldValue != currentZoomType else {
                return
            }

            mapManager?.updateForZoomType(currentZoomType)
        }
    }

    @objc func longPress(gestureRecognizer: UIGestureRecognizer) {
        mapManager?.longPress()
    }

    @objc func tap(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            let coord = mapView.convert(tap.location(in: mapView), toCoordinateFrom: mapView)
            let touchLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

            for overlay: MKOverlay in mapView.overlays {
                if let overlay = overlay as? ImageOverlay {
                    let location = CLLocation(latitude: overlay.coordinate.latitude, longitude: overlay.coordinate.longitude)
                    let distance = location.distance(from: touchLocation)
                    if distance < 30 {
                        reportViewController?.quickLookImages(assets: overlay.assets)
                        return
                    }
                }
            }
        }
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool, purchasedHistory: Bool, geoDB: GeoDatabase, context: NSManagedObjectContext) {
        GeometryOverlayCreator.overlayVersion += 1

        switch currentTab {
        case .countries:
            if !(self.mapManager is CountriesMapManager) {
                mapManager?.unload()
                mapManager = CountriesMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
            }

        case .states:
            if !(self.mapManager is StatesMapManager) {
                mapManager?.unload()
                mapManager = StatesMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
            }

        case .places:
            if !(self.mapManager is HeatmapMapManager) {
                mapManager?.unload()
                mapManager = HeatmapMapManager(mapView: mapView, mapViewDelegate: self, context: context)
            }

        case .cities:
            if !(self.mapManager is CitiesMapManager) {
                mapManager?.unload()
                mapManager = CitiesMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
            }

        case .continents:
            if !(self.mapManager is ContinentsMapManager) {
                mapManager?.unload()
                mapManager = ContinentsMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
            }

        case .timezones:
            if !(self.mapManager is TimezoneMapManager) {
                mapManager?.unload()
                mapManager = TimezoneMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
            }
        }

        DispatchQueue.global(qos: .background).async {
            self.mapManager?.load(currentTab: currentTab, year: year, cumulative: cumulative, purchasedHistory: purchasedHistory)
            self.removeOldOverlays()

            DispatchQueue.main.async {
                self.mapManager?.viewChanged(visibleMapRect: self.mapView.visibleMapRect)
            }
        }
    }

    func addGeometryToMap(_ geometry: Geometry, properties: MapOverlayProperties) {
        DispatchQueue.main.sync {
            GeometryOverlayCreator.addOverlayToMap(geometry: geometry,
                                                   properties: properties,
                                                   mapView: self.mapView)
        }
    }

    func addCircleToMap(center: CLLocationCoordinate2D,
                        radius: CLLocationDistance,
                        properties: MapOverlayProperties) {
        DispatchQueue.main.sync {
            GeometryOverlayCreator.addCircleToMap(center: center,
                                                  radius: radius,
                                                  properties: properties,
                                                  mapView: self.mapView)
        }
    }

    func addOverlayToMap(_ overlay: MKOverlay, overlayVersion: Int) {
        DispatchQueue.main.sync {
            if overlayVersion < GeometryOverlayCreator.overlayVersion { return }
            mapView.add(overlay)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let mapPolygon = overlay as? MapPolygon,
            let properties = mapPolygon.properties {
            let polygonView = PolygonRenderer(overlay: overlay)

            if let fillColor = properties.fillColor {
                if let alpha = properties.alpha {
                    polygonView.fillColor = fillColor.withAlphaComponent(alpha)
                } else {
                    polygonView.fillColor = fillColor
                }
            }
            if let strokeColor = properties.strokeColor {
                polygonView.strokeColor = strokeColor
            }
            if let lineWidth = properties.lineWidth {
                polygonView.lineWidth = lineWidth
            }

            return polygonView
        } else if overlay is ImageOverlay {
            return ImageOverlayRenderer(overlay: overlay)
        } else if let polyline = overlay as? MapPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.lineWidth = polyline.properties?.lineWidth ?? 1
            renderer.strokeColor = polyline.properties?.strokeColor ?? #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            return renderer
        } else if let circle = overlay as? MapCircle {
            let renderer = MKCircleRenderer(overlay: circle)
            renderer.lineWidth = circle.properties?.lineWidth ?? 3
            renderer.strokeColor = circle.properties?.strokeColor ?? #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            return renderer
        } else {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 2
            renderer.strokeColor = UIColor.white
            return renderer
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapManager?.viewFor(annotation: annotation)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.region.span.latitudeDelta < 7.5 {
            currentZoomType = .close
        } else if mapView.region.span.latitudeDelta < 15 {
            currentZoomType = .medium
        } else {
            currentZoomType = .far
        }

        mapManager?.viewChanged(visibleMapRect: mapView.visibleMapRect)
    }

    func removeOldOverlays() {
        DispatchQueue.main.sync {
            GeometryOverlayCreator.removeOldOverlays(mapView: self.mapView)
        }
    }

}
