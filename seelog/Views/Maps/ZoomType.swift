//
//  ZoomType.swift
//  seelog
//
//  Created by Matus Tomlein on 19/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

enum ZoomType {
    case close
    case medium
    case far
}

extension ZoomType {
    static func zoomTypeForMapRect(_ mapRect: MKMapRect, threeLevels: Bool = true) -> ZoomType {
        let width = mapRect.width

        if threeLevels {
            if width > 35000000 { return .far }
            if width > 6000000 { return .medium }
            return .close
        } else {
            return width > 10000000 ? .far : .close
        }
    }
}
