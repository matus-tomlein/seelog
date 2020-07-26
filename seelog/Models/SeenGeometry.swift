//
//  SeenGeometry.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Location: Hashable {
    let lat: Double
    let lng: Double
}

struct SeenGeometry: Identifiable {
    var id: Int { get { return year ?? 0 } }
    var isTotal: Bool { get { return self.year == nil } }
    var year: Int?
    var month: Int?
    var geohashes: Set<String>
    var travelledDistance: Double
    var landWKT: String
    var waterWKT: String
    var processedWKT: String
    var higherLevelPositions: [Location] {
        return toPositions(geohashes: Array(Set(geohashes.map { geohash in String(geohash.prefix(3)) })))
    }
    var positions: [Location] {
        return toPositions(geohashes: Array(geohashes))
    }
    
    private func toPositions(geohashes: [String]) -> [Location] {
        Array(
            Set(geohashes.map { geohash -> Location in
                let decoded = Geohash.decode(hash: geohash)!
                return Location(
                    lat: round((decoded.latitude.max + decoded.latitude.min) / 2 * 10) / 10,
                    lng: round((decoded.longitude.max + decoded.longitude.min) / 2 * 10) / 10
                )
            })
        )
    }
}
