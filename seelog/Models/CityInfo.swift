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
    var stateKey: String?
    var continent: String
    var name: String
    var latitude: Double
    var longitude: Double
    var countryKey: String
    var populationMin: Int
    var populationMax: Int
    var worldCity: Bool
    var megaCity: Bool

    init(cityKey: Int64, name: String, stateKey: String?, continent: String, latitude: Double, longitude: Double, countryKey: String, populationMin: Int, populationMax: Int, worldCity: Bool, megaCity: Bool) {
        self.cityKey = cityKey
        self.name = name
        self.stateKey = stateKey
        self.continent = continent
        self.latitude = latitude
        self.longitude = longitude
        self.countryKey = countryKey
        self.populationMin = populationMin
        self.populationMax = populationMax
        self.worldCity = worldCity
        self.megaCity = megaCity
    }
}
