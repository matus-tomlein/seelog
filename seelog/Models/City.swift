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
    var name: String { return cityInfo.name }
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

    func info(year: Int?) -> TextInfo {
        let link = ViewLink.city(self)
        if !visited(year: year) {
            return TextInfo(id: String(id), link: link, heading: cityInfo.name, status: .notVisited, enabled: false)
        }
        
        return TextInfo(
            id: String(id),
            link: link,
            heading: cityInfo.name,
            status: status(year: year),
            body: [
                stayDurationInfo(year: year)
            ]
        )
    }
    
    func explored(year: Int?) -> Bool? {
        return nil
    }
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
