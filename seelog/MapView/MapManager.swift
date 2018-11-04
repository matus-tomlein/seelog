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
    func load(year: Year, cumulative: Bool)
    func updateForZoomType(_ zoomType: ZoomType)
    func longPress()
    func rendererFor(polygon: MKPolygon) -> MKOverlayRenderer?
    func nonPolygonRendererFor(overlay: MKOverlay) -> MKOverlayRenderer?
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView?
}
