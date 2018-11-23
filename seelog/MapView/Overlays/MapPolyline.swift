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
            MKMapPointMake(Double(rect.minX), Double(rect.minY)),
            MKMapPointMake(Double(rect.maxX), Double(rect.minY)),
            MKMapPointMake(Double(rect.maxX), Double(rect.maxY)),
            MKMapPointMake(Double(rect.minX), Double(rect.maxY)),
            MKMapPointMake(Double(rect.minX), Double(rect.minY))
            ], count: 5)
    }

    func getProperties() -> MapOverlayProperties? { return self.properties }
}
