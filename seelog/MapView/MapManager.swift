//
//  MapManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

protocol MapManager {
    func load(mapViewDelegate: MainMapViewDelegate)
    func unload(mapViewDelegate: MainMapViewDelegate)
    func updateForZoomType(_ zoomType: ZoomType, mapViewDelegate: MainMapViewDelegate)
    func viewChanged(visibleMapRect: MKMapRect, mapViewDelegate: MainMapViewDelegate)
    func longPress(mapViewDelegate: MainMapViewDelegate)
    func viewFor(annotation: MKAnnotation, mapViewDelegate: MainMapViewDelegate) -> MKAnnotationView?
}
