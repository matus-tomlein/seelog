//
//  MapOverlayProperties.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

enum PolygonType: String {
    case heatmap = "h"
    case heatmapWater = "hw"
    case heatmapLand = "hl"
    case country = "c"
    case state = "s"
}

class MapOverlayProperties {
    var overlayVersion: Int
    var zoomTypes: [ZoomType]?
    var polygonType: PolygonType?
    var alpha: CGFloat?
    var fillColor: UIColor?
    var strokeColor: UIColor?
    var lineWidth: CGFloat?

    init(_ overlayVersion: Int) {
        self.overlayVersion = overlayVersion
    }

    init(zoomTypes: [ZoomType], overlayVersion: Int) {
        self.overlayVersion = overlayVersion
        self.zoomTypes = zoomTypes
    }
}
