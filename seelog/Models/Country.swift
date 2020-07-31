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
    var name: String { return countryInfo.name }
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

    func positions(year: Int?) -> [Location] {
        return model.positions(
            year: year,
            minLatitude: self.countryInfo.minLatitude,
            maxLatitude: self.countryInfo.maxLatitude,
            minLongitude: self.countryInfo.minLongitude,
            maxLongitude: self.countryInfo.maxLongitude
        )
    }

    func info(year: Int?) -> TextInfo {
        let link = ViewLink.country(self)
        if !visited(year: year) {
            return TextInfo(id: id, link: link, heading: countryInfo.name, status: .notVisited, enabled: false)
        }

        return TextInfo(
            id: id,
            link: link,
            heading: countryInfo.name,
            status: status(year: year),
            body: [
                stayDurationInfo(year: year),
                explorationInfo(year: year)
            ]
        )
    }
    
    func explorationInfo(year: Int?) -> String {
        let regions = regionsForYear(year)
        var sentences: [String] = []
        if regions.count < 3 {
            let regionNames = regions.map { $0.stateInfo.name }.joined(separator: ", ")
            sentences.append(
                "\(regions.count) regions (\(regionNames)) out of \(countryInfo.numberOfRegions)."
            )
        } else {
            sentences.append(
                "\(regions.count) out of \(countryInfo.numberOfRegions) regions."
            )
        }
        let cities = citiesForYear(year: year)
        if cities.count > 0 {
            if cities.count < 3 {
                let cityNames = cities.map { $0.cityInfo.name }.joined(separator: " and ")
                sentences.append(
                    "Visited \(cityNames)."
                )
            } else {
               sentences.append(
                   "\(cities.count) cities."
               )
            }
        }
        return sentences.joined(separator: " ")
    }

    func explored(year: Int?) -> Bool? {
        let regionsCount = regionsForYear(year).count
        let citiesCount = citiesForYear(year: year).count
        return citiesCount >= 5 || regionsCount >= 10 || Double(regionsCount) / Double(countryInfo.numberOfRegions) > 0.66
    }
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
