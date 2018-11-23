//
//  MapOverlay.swift
//  seelog
//
//  Created by Matus Tomlein on 23/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

protocol MapOverlay {
    func getProperties() -> MapOverlayProperties?
}
