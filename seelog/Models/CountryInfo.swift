//
//  CountryInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 14/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

struct CountryInfo {
    var countryKey: String
    var name: String
    var continent: String
    var region: String
    var subregion: String
    var latitude: Double
    var longitude: Double
    var minLatitude: Double
    var minLongitude: Double
    var maxLatitude: Double
    var maxLongitude: Double
    var geometry10mBytes: [UInt8]
    var geometry50mBytes: [UInt8]?
    var geometry110mBytes: [UInt8]?
    var numberOfRegions: Int

    init(countryKey: String,
         name: String,
         geometry10mBytes: [UInt8],
         geometry50mBytes: [UInt8]?,
         geometry110mBytes: [UInt8]?,
         latitude: Double,
         longitude: Double,
         minLatitude: Double,
         minLongitude: Double,
         maxLatitude: Double,
         maxLongitude: Double,
         continent: String,
         region: String,
         subregion: String,
         numberOfRegions: Int) {
        self.countryKey = countryKey
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.minLatitude = minLatitude
        self.minLongitude = minLongitude
        self.maxLatitude = maxLatitude
        self.maxLongitude = maxLongitude
        self.geometry10mBytes = geometry10mBytes
        self.geometry50mBytes = geometry50mBytes
        self.geometry110mBytes = geometry110mBytes
        self.continent = continent
        self.region = region
        self.subregion = subregion
        self.numberOfRegions = numberOfRegions
    }

    var geometry10m: Geometry? {
        get {
            return try? Geometry(wkb: Data(geometry10mBytes))
        }
    }

    var geometry50m: Geometry? {
        get {
            if let bytes = geometry50mBytes {
                return try? Geometry(wkb: Data(bytes))
            }
            return nil
        }
    }

    var geometry110m: Geometry? {
        get {
            if let bytes = geometry110mBytes {
                return try? Geometry(wkb: Data(bytes))
            }
            return nil
        }
    }
    
    var geometry10mDescription: GeometryDescription {
        GeometryDescription(
            geometry: geometry10m ?? geometry50m ?? geometry110m,
            minLatitude: minLatitude,
            minLongitude: minLongitude,
            maxLatitude: maxLatitude,
            maxLongitude: maxLongitude
        )
    }
    
    var geometry50mDescription: GeometryDescription {
        GeometryDescription(
            geometry: geometry50m ?? geometry10m ?? geometry110m,
            minLatitude: minLatitude,
            minLongitude: minLongitude,
            maxLatitude: maxLatitude,
            maxLongitude: maxLongitude
        )
    }
    
    var geometry110mDescription: GeometryDescription {
        GeometryDescription(
            geometry: geometry110m ?? geometry50m ?? geometry10m,
            minLatitude: minLatitude,
            minLongitude: minLongitude,
            maxLatitude: maxLatitude,
            maxLongitude: maxLongitude
        )
    }
    
    var badgeGeometryDescription: GeometryDescription {
        if maxLatitude - minLatitude < 2 {
            return geometry10mDescription
        } else if maxLatitude - minLatitude < 5 {
            return geometry50mDescription
        } else {
            return geometry110mDescription
        }
    }
    
    func geometry(zoomType: ZoomType) -> GeometryDescription {
        switch zoomType {
        case .far:
            return geometry110mDescription
        case .medium:
            return geometry50mDescription
        case .close:
            return geometry10mDescription
        }
    }
}
