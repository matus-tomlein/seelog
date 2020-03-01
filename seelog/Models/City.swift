//
//  City.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct City: Identifiable, Trippable {
    var id: Int64 { return cityInfo.cityKey }
    var cityInfo: CityInfo
    var model: DomainModel
    
    var continent: Continent { return model.continent(id: cityInfo.continent) }
    var country: Country { return model.country(id: cityInfo.countryKey) }
    var region: Region? {
        if let stateKey = self.cityInfo.stateKey { return model.region(id: stateKey) }
        return nil
    }

    var stayDurationByYear: [Int: Int]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]
}

extension City {
    init(cityInfo: CityInfo, trips: [Trip], model: DomainModel) {
        self.cityInfo = cityInfo
        self.model = model
        self.trips = trips

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
}
