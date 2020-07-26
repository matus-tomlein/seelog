//
//  Continent.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Continent: Identifiable, Trippable {
    var id: String { get { return continentInfo.name } }
    var continentInfo: ContinentInfo
    var model: DomainModel

    var cities: [City] { return model.cities.filter { $0.cityInfo.continent == self.id } }
    var countries: [Country] { return model.countries.filter { $0.countryInfo.continent == self.id } }
    var stayDurationByYear: [Int: Int]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]
}

extension Continent {
    init(continentInfo: ContinentInfo, trips: [Trip], model: DomainModel) {
        self.continentInfo = continentInfo
        self.model = model
        self.trips = trips

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
    
    func citiesForYear(_ year: Int?) -> [City] {
        if let year = year {
            return cities.filter { city in city.years.contains(year) }
        } else {
            return cities
        }
    }
    
    func countriesForYear(_ year: Int?) -> [Country] {
        if let year = year {
            return countries.filter { country in country.years.contains(year) }
        } else {
            return countries
        }
    }

    func explorationStatusForYear(_ year: Int?) -> ExplorationStatus {
        let explorationRatio = Double(countriesForYear(year).count) / Double(continentInfo.numberOfCountries)
        
        if explorationRatio < 0.33 {
            return .visitor
        } else if explorationRatio < 0.66 {
            return .explorer
        } else {
            return .conqueror
        }
    }
}
