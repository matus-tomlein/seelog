//
//  SphericalMercator.swift
//  seelog
//
//  Created by Matus Tomlein on 19/04/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

class SphericalMercator {
    private let radius: Double = 6378137.0; /* in meters on the equator */

    let r_major = 6378137.000
    let r_minor = 6356752.3142

    /* These functions take their angle parameter in degrees and return a length in meters */

    func lat2y(aLat: Double) -> Double {
        var lat = aLat
        if lat > 89.5 { lat = 89.5 }
        if lat <= -89.5 { lat = -89.5 }
        let temp = r_minor / r_major
        let eccent = sqrt(1 - pow(temp, 2))
        let phi = toRadians(degrees: lat)
        let sinphi = sin(phi)
        var con = eccent * sinphi
        let com = eccent / 2
        con = pow(((1.0 - con) / (1.0 + con)), com)
        let ts = tan((Double.pi / 2 - phi) / 2) / con
        let y = 0 - r_major * log(ts)
        return y
    }

    func lon2x(aLong: Double) -> Double {
        return r_major * toRadians(degrees: aLong)
    }

    func toRadians(degrees: Double) -> Double {
        (degrees / (180 / Double.pi))
    }

    func toDegrees(radians: Double) -> Double {
        radians * 180 / Double.pi
    }
}
