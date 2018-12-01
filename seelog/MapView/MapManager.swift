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
    func load(currentTab: SelectedTab, year: Year, cumulative: Bool)
    func unload()
    func updateForZoomType(_ zoomType: ZoomType)
    func viewChanged(visibleMapRect: MKMapRect)
    func longPress()
    func viewFor(annotation: MKAnnotation) -> MKAnnotationView?
}
