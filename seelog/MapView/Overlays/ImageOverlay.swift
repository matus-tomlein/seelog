//
//  ImageOverlay.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

class ImageOverlay : NSObject, MKOverlay, MapOverlay {

    var image: UIImage?
    let boundingMapRect: MKMapRect
    let coordinate: CLLocationCoordinate2D
    var properties: MapOverlayProperties?

    init(image: UIImage, rect: MKMapRect, properties: MapOverlayProperties) {
        self.image = image
        self.boundingMapRect = rect
        self.coordinate = rect.origin.coordinate
        self.properties = properties
    }

    func getProperties() -> MapOverlayProperties? {
        return properties
    }
}
