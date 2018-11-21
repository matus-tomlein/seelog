//
//  CitiesMapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

class MajorCityCircle: MKCircle {}
class SmallerCityCircle: MKCircle {}

class CitiesMapManager: MapManager {
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var geoDB: GeoDatabase

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, geoDB: GeoDatabase) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.geoDB = geoDB
    }

    func unload() {
        mapView.removeOverlays(mapView.overlays)
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool) {
        mapView.mapType = .mutedStandard
        
        guard let cityInfos = year.cityInfos(cumulative: cumulative, geoDB: geoDB) else { return }
        let majorCities = cityInfos.filter({ $0.worldCity || $0.megaCity })
        let smallerCities = cityInfos.filter({ !$0.worldCity && !$0.megaCity })

        for cityInfo in smallerCities {
            let circle = SmallerCityCircle(center: CLLocationCoordinate2D(latitude: cityInfo.latitude, longitude: cityInfo.longitude), radius: 1000)
            mapView.add(circle)
        }

        for cityInfo in majorCities {
            let circle = MajorCityCircle(center: CLLocationCoordinate2D(latitude: cityInfo.latitude, longitude: cityInfo.longitude), radius: 1000)
            mapView.add(circle)
        }
    }

    func updateForZoomType(_ zoomType: ZoomType) {
        for case let annot as Annotation in mapView.annotations {
            mapView.view(for: annot)?.isHidden = !annot.zoomTypes.contains(zoomType)
        }
    }

    func viewChanged(visibleMapRect: MKMapRect) {}

    func longPress() {
    }

    func rendererFor(polygon: MKPolygon) -> MKOverlayRenderer? {
        return nil
    }

    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer? {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = overlay is MajorCityCircle ? UIColor.red : mapView.tintColor
        return renderer
    }

    func viewFor(annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else { return nil }

        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: "city")
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "city")
            view.alpha = 0
//            if annotation is StateAnnotation {
//                view.markerTintColor = UIColor.lightGray
//                view.displayPriority = .defaultLow
//                view.alpha = 0
//            } else if annotation is CountryAnnotation {
//                view.displayPriority = .defaultHigh
//            }
        }
        view.isHidden = !annotation.zoomTypes.contains(mapViewDelegate.currentZoomType)
        return view
    }

}