//
//  CustomMapView.swift
//  seelog
//
//  Created by Matus Tomlein on 14/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

class MapView: MKMapView {
    var mapViewDelegate: MainMapViewDelegate?
    var world: Bool
    
    init(world: Bool) {
        self.world = world
        super.init(frame: .zero)

        if world {
            self.visibleMapRect = .world
            self.mapType = .satelliteFlyover
        } else {
            self.mapType = .standard
        }
        self.isRotateEnabled = false
        self.isPitchEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDelegate(mapManager: MapManager) -> MainMapViewDelegate {
        if let delegate = mapViewDelegate {
            return delegate
        } else {
            let delegate = MainMapViewDelegate(mapView: self, mapManager: mapManager)
            self.mapViewDelegate = delegate
            self.delegate = delegate
            return delegate
        }
    }
}
