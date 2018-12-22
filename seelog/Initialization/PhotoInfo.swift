//
//  PhotoInfo.swift
//  Seelog
//
//  Created by Matus Tomlein on 17/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class PhotoInfo {
    let geohash: String?
    var countryKey: String?
    var stateKey: String?
    var continent: String?
    var timezone: Int32?
    let creationDate: Date?
    var cities: [Int64] = []
    let year: Int32

    init(photo: Photo, geoDB: GeoDatabase) {
        self.geohash = photo.geohash
        self.year = photo.year
        self.creationDate = photo.creationDate

        if let geohash = self.geohash {
            self.countryKey = geoDB.countryKeyFor(geohash: geohash)
            self.stateKey = geoDB.stateKeyFor(geohash: geohash)
            self.continent = geoDB.continentFor(geohash: geohash)
            self.timezone = geoDB.timezoneFor(geohash: geohash)
            self.cities = geoDB.cityKeysFor(geohash: geohash)
        }
    }
}
