//
//  ImageOverlay.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import Photos

class ImageOverlay : NSObject, MKOverlay, MapOverlay {

    var image: UIImage?
    var assets: [PHAsset]
    let boundingMapRect: MKMapRect
    let coordinate: CLLocationCoordinate2D
    var properties: MapOverlayProperties?
    weak var polyline: MapPolyline?

    init(image: UIImage, assets: [PHAsset], coordinate: CLLocationCoordinate2D, properties: MapOverlayProperties) {
        self.image = image
        self.assets = assets
        self.coordinate = coordinate
        self.properties = properties
        self.boundingMapRect = ImageOverlay.initBoundingMapRect(image: image, coordinate: coordinate)
    }

    func getProperties() -> MapOverlayProperties? {
        return properties
    }

    func addTo(mapView: MKMapView) {
        guard let properties = self.properties else { return }

        let polylineOverlay = MapPolyline(rect: boundingMapRect)
        let polylineProperties = MapOverlayProperties(properties.overlayVersion)
        polylineProperties.lineWidth = 3
        polylineOverlay.properties = polylineProperties
        mapView.addOverlay(polylineOverlay)
        self.polyline = polylineOverlay

        mapView.addOverlay(self)
    }

    func removeFrom(mapView: MKMapView) {
        mapView.removeOverlay(self)
        if let polyline = self.polyline { mapView.removeOverlay(polyline) }
        self.polyline = nil
    }

    private static func initBoundingMapRect(image: UIImage, coordinate: CLLocationCoordinate2D) -> MKMapRect {
        let multiplyBy = 640 / ([Double(image.size.width), Double(image.size.height)].max() ?? 0)

        let size = MKMapSize(width: Double(image.size.width) * multiplyBy, height: Double(image.size.height) * multiplyBy)
        var origin = MKMapPoint(coordinate)
        origin.x -= size.width / 2
        origin.y -= size.height / 2
        return MKMapRect(origin: origin, size: size)
    }
}
