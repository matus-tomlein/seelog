//
//  State.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Region: Identifiable, Trippable {
    var id: String { get { return stateInfo.stateKey } }
    var name: String { return stateInfo.name }
    var stateInfo: StateInfo
    var model: DomainModel

    var cities: [City] { return model.cities.filter { city in city.cityInfo.stateKey == self.id } }
    var country: Country { return model.country(id: stateInfo.countryKey) }
    var continent: Continent { return model.continent(id: stateInfo.continent) }
    var stayDurationByYear: [Int: Int]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]

    func positions(year: Int?) -> [Location] {
        return model.positions(
            year: year,
            minLatitude: self.stateInfo.minLatitude,
            maxLatitude: self.stateInfo.maxLatitude,
            minLongitude: self.stateInfo.minLongitude,
            maxLongitude: self.stateInfo.maxLongitude
        )
    }

    func info(year: Int?) -> TextInfo {
        let link = ViewLink.region(self)
        if !visited(year: year) {
            return TextInfo(id: id, link: link, heading: stateInfo.name, status: .notVisited, enabled: false)
        }
        
        return TextInfo(
            id: id,
            link: link,
            heading: stateInfo.name,
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

extension Region {
    init(stateInfo: StateInfo, trips: [Trip], model: DomainModel) {
        self.stateInfo = stateInfo
        self.trips = trips
        self.model = model

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
    
    func citiesForYear(year: Int?) -> [City] {
        if let year = year {
            return cities.filter { city in city.years.contains(year) }
        } else {
            return cities
        }
    }
}
