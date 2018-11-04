//
//  CityInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 14/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

struct CityInfo {
    var cityKey: Int64
    var name: String
    var latitude: Double
    var longitude: Double
    var countryKey: String
    var populationMin: Int
    var populationMax: Int

    init(cityKey: Int64, name: String, latitude: Double, longitude: Double, countryKey: String, populationMin: Int, populationMax: Int) {
        self.cityKey = cityKey
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.countryKey = countryKey
        self.populationMin = populationMin
        self.populationMax = populationMax
    }
}
