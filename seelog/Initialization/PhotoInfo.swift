//
//  PhotoInfo.swift
//  Seelog
//
//  Created by Matus Tomlein on 17/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class PhotoInfo {
    let geohash4: String
    let geohash5: String
    var countryKey: String?
    var stateKey: String?
    var continent: String?
    var timezone: Int32?
    let creationDate: Date?
    var cities: [Int64] = []
    let year: Int32

    init(photo: Photo, geoDB: GeoDatabase) {
        self.geohash4 = photo.geohash ?? Geohash.encode(latitude: photo.latitude, longitude: photo.longitude, length: 4)
        self.geohash5 = Geohash.encode(latitude: photo.latitude, longitude: photo.longitude, length: 5)
        self.year = photo.year
        self.creationDate = photo.creationDate

        self.countryKey = geoDB.countryKeyFor(geohash: geohash5)
        self.stateKey = geoDB.stateKeyFor(geohash: geohash5)
        self.cities = geoDB.cityKeysFor(geohash: geohash5)
        self.continent = geoDB.continentFor(geohash: geohash4)
        self.timezone = geoDB.timezoneFor(geohash: geohash4)
    }
}
