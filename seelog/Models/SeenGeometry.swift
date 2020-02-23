//
//  SeenGeometry.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct SeenGeometry: Identifiable {
    var id: Int { get { return year ?? 0 } }
    var isTotal: Bool { get { return self.year == nil } }
    var year: Int?
    var geohashes: Set<String>
    var landWKT: String
    var waterWKT: String
    var processedWKT: String
    var positions: [(lat: Double, lng: Double)] {
        get {
            geohashes.map { geohash in
                let decoded = Geohash.decode(hash: geohash)!
                return (
                    lat: (decoded.latitude.max + decoded.latitude.min) / 2,
                    lng: (decoded.longitude.max + decoded.longitude.min) / 2
                )
            }
        }
    }
}
