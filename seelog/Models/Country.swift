//
//  Country.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Country: Identifiable, Trippable {
    var id: String { return countryInfo.countryKey }
    var countryInfo: CountryInfo
    var model: DomainModel

    var stayDurationByYear: [Int: Int]
    var regions: [Region] { return model.states.filter { $0.stateInfo.countryKey == id } }
    var cities: [City] { return model.cities.filter { $0.cityInfo.countryKey == id } }
    var continent: Continent { return model.continent(id: countryInfo.continent) }
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]
}

extension Country {
    init(countryInfo: CountryInfo, trips: [Trip], model: DomainModel) {
        self.countryInfo = countryInfo
        self.model = model
        self.trips = trips

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
    
    func statesForYear(year: Int?) -> [Region] {
        if let year = year {
            return regions.filter { state in state.years.contains(year) }
        } else {
            return regions
        }
    }
    
    func citiesForYear(year: Int?) -> [City] {
        if let year = year {
            return cities.filter { city in city.years.contains(year) }
        } else {
            return cities
        }
    }

    func regionsForYear(_ year: Int?) -> [Region] {
        if let year = year {
            return regions.filter { region in region.years.contains(year) }
        } else {
            return regions
        }
    }
    
    func explorationStatusForYear(_ year: Int?) -> ExplorationStatus {
        let explorationRatio = Double(regionsForYear(year).count) / Double(countryInfo.numberOfRegions)
        
        if explorationRatio < 0.33 {
            return .visitor
        } else if explorationRatio < 0.66 {
            return .explorer
        } else {
            return .conqueror
        }
    }
}
