//
//  MapPolyline.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

class MapPolyline : MKPolyline, MapOverlay {
    var properties: MapOverlayProperties?

    convenience init(rect: MKMapRect) {
        self.init(points: [
            MKMapPoint(x: Double(rect.minX), y: Double(rect.minY)),
            MKMapPoint(x: Double(rect.maxX), y: Double(rect.minY)),
            MKMapPoint(x: Double(rect.maxX), y: Double(rect.maxY)),
            MKMapPoint(x: Double(rect.minX), y: Double(rect.maxY)),
            MKMapPoint(x: Double(rect.minX), y: Double(rect.minY))
            ], count: 5)
    }

    func getProperties() -> MapOverlayProperties? { return self.properties }
}
