//
//  MapCircle.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

class MapCircle : MKCircle, MapOverlay {
    var properties: MapOverlayProperties?

    func getProperties() -> MapOverlayProperties? {
        return properties
    }
}
