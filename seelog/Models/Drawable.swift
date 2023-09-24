//
//  Drawable.swift
//  seelog
//
//  Created by Matus Tomlein on 26/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift
import MapKit

protocol Drawable {
    var _id: String { get }
    var coordinateRegion: MKCoordinateRegion { get }
    func polygons(zoomType: ZoomType) -> [Polygon]
    func intersects(mapRegion: MKCoordinateRegion) -> Bool
}
