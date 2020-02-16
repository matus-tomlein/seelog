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

class CitiesMapManager: MapManager {
    private var cities: [City]
    private let circleRadius: Double = 10000
    private let lineWidth: CGFloat = 3

    init(cities: [City], mapView: MKMapView) {
        self.cities = cities
    }

    func unload(mapViewDelegate: MainMapViewDelegate) {
        let mapView = mapViewDelegate.mapView
        mapView.removeOverlays(mapView.overlays)
    }

    func load(mapViewDelegate: MainMapViewDelegate) {
        let overlayVersion = GeometryOverlayCreator.overlayVersion
        
        let majorCities = cities.filter({ $0.cityInfo.worldCity || $0.cityInfo.megaCity })
        let smallerCities = cities.filter({ !$0.cityInfo.worldCity && !$0.cityInfo.megaCity })

        for city in smallerCities {
            let properties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                  overlayVersion: overlayVersion)
            properties.strokeColor = mapViewDelegate.mapView.tintColor
            properties.lineWidth = lineWidth
            mapViewDelegate.addCircleToMap(center: CLLocationCoordinate2D(latitude: city.cityInfo.latitude, longitude: city.cityInfo.longitude),
                                           radius: circleRadius,
                                           properties: properties)
        }

        for city in majorCities {
            let properties = MapOverlayProperties(zoomTypes: [.close, .medium, .far],
                                                  overlayVersion: overlayVersion)
            properties.strokeColor = UIColor.red
            properties.lineWidth = lineWidth
            mapViewDelegate.addCircleToMap(center: CLLocationCoordinate2D(latitude: city.cityInfo.latitude, longitude: city.cityInfo.longitude),
                                           radius: circleRadius,
                                           properties: properties)
        }
    }

    func updateForZoomType(_ zoomType: ZoomType, mapViewDelegate: MainMapViewDelegate) {
        let mapView = mapViewDelegate.mapView
        for case let annot as Annotation in mapView.annotations {
            mapView.view(for: annot)?.isHidden = !annot.zoomTypes.contains(zoomType)
        }
    }

    func viewChanged(visibleMapRect: MKMapRect, mapViewDelegate: MainMapViewDelegate) {}

    func longPress(mapViewDelegate: MainMapViewDelegate) {
    }

    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else { return nil }

        var view: MKMarkerAnnotationView
        if let dequeuedView = mapViewDelegate.mapView.dequeueReusableAnnotationView(withIdentifier: "city")
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
