//
//  Country.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Country: Identifiable, Trippable {
    var id: String { get { return countryInfo.countryKey } }
    var countryInfo: CountryInfo

    var stayDurationByYear: [Int: Int]
    var states: [Region]
    var cities: [City]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]
}

extension Country {
    init(countryInfo: CountryInfo, states: [Region], cities: [City], trips: [Trip]) {
        self.countryInfo = countryInfo
        self.states = states
        self.cities = cities
        self.trips = trips

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
    
    func statesForYear(year: Int?) -> [Region] {
        if let year = year {
            return states.filter { state in state.years.contains(year) }
        } else {
            return states
        }
    }
    
    func citiesForYear(year: Int?) -> [City] {
        if let year = year {
            return cities.filter { city in city.years.contains(year) }
        } else {
            return cities
        }
    }
}
