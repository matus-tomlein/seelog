//
//  DomainModel.swift
//  seelog
//
//  Created by Matus Tomlein on 12/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import SwiftCSV

class DomainModel {
    var world: World
    var countries: [Country] = []
    var states: [Region] = []
    var timezones: [Timezone] = []
    var continents: [Continent] = []
    var continentInfos: [ContinentInfo] = []
    var cities: [City] = []
    var years: [Year] = []
    var seenGeometry: SeenGeometry?
    var geoDatabase: GeoDatabase
    var countryYearCounts: [(year: Int, count: Int)] {
        get { return years.reversed().map { year in (year: year.year, count: year.countries.count) } }
    }
    var continentYearCounts: [(year: Int, count: Int)] {
        get { return years.reversed().map { year in (year: year.year, count: year.continents.count) } }
    }
    var timezonesYearCounts: [(year: Int, count: Int)] {
        get { return years.reversed().map { year in (year: year.year, count: year.timezones.count) } }
    }
    var cityYearCounts: [(year: Int, count: Int)] {
        get { return years.reversed().map { year in (year: year.year, count: year.cities.count) } }
    }
    var totalYearCounts: [(year: Int, count: Int)] {
        get {
            return years.reversed().map { year in
                (
                    year: year.year,
                    count: year.countries.count + year.continents.count + year.timezones.count + year.cities.count
                )
            }
        }
    }

    init(trips: [Trip], seenGeometries: [SeenGeometry], geoDatabase: GeoDatabase) {
        self.world = World(trips: trips)
        self.seenGeometry = seenGeometries.first { $0.isTotal }
        self.geoDatabase = geoDatabase
        self.continentInfos = geoDatabase.allContinents()

        let tripsByType = Dictionary(grouping: trips, by: { $0.visitedEntityType }).mapValues { trips in Dictionary(grouping: trips, by: { $0.visitedEntityKey }) }
        var countryTrips: [(countryInfo: CountryInfo, trips: [Trip])] = []

        for (type, tripsByPlace) in tripsByType {
            for (entityKey, trips) in tripsByPlace {
                switch type {
                case .country:
                    if let countryInfo = geoDatabase.countryInfoFor(countryKey: entityKey) {
                        countryTrips.append((countryInfo: countryInfo, trips: trips))
                    }
                    
                case .state:
                    if let stateInfo = geoDatabase.stateInfoFor(stateKey: entityKey) {
                        states.append(Region(stateInfo: stateInfo, trips: trips))
                    }
                    
                case .timezone:
                    if let timezoneId = Int32(entityKey),
                        let timezoneInfo = geoDatabase.timezoneInfoFor(timezoneId: timezoneId) {
                        timezones.append(Timezone(timezoneInfo: timezoneInfo, trips: trips))
                    }

                case .city:
                    if let cityKey = Int64(entityKey),
                        let cityInfo = geoDatabase.cityInfoFor(cityKey: cityKey) {
                        cities.append(City(cityInfo: cityInfo, trips: trips))
                    }

                case .continent:
                    if let continentInfo = geoDatabase.continentInfoFor(name: entityKey) {
                        continents.append(Continent(continentInfo: continentInfo, trips: trips))
                    }
                }
            }
        }

        countries = countryTrips.map { (countryInfo, trips) in
            let countryStates = states.filter { state in state.stateInfo.countryKey == countryInfo.countryKey }
            let countryCities = cities.filter { city in city.cityInfo.countryKey == countryInfo.countryKey }
            return Country(countryInfo: countryInfo, states: countryStates, cities: countryCities, trips: trips)
        }
        countries = countries.sorted(by: { $0.countryInfo.name < $1.countryInfo.name })
        states = states.sorted(by: { $0.stateInfo.name < $1.stateInfo.name })
        timezones = timezones.sorted(by: { $0.timezoneInfo.name < $1.timezoneInfo.name })
        cities = cities.sorted(by: { $0.cityInfo.name < $1.cityInfo.name })
        continents = continents.sorted(by: { $0.continentInfo.name < $1.continentInfo.name })

        var years = Set(trips.flatMap { trip in trip.years })
        years.insert(Date().year())
        self.years = years.map { year in
            let yearCountries = countries.filter { country in
                !country.trips.filter { trip in trip.years.contains(year) }.isEmpty
            }
            let yearStates = states.filter { state in
                !state.trips.filter { trip in trip.years.contains(year) }.isEmpty
            }
            let yearTimezones = timezones.filter { timezone in
                !timezone.trips.filter { trip in trip.years.contains(year) }.isEmpty
            }
            let yearContinents = continents.filter { continent in
                !continent.trips.filter { trip in trip.years.contains(year) }.isEmpty
            }
            let yearCities = cities.filter { city in
                !city.trips.filter { trip in trip.years.contains(year) }.isEmpty
            }
            return Year(
                year: year,
                cities: yearCities,
                countries: yearCountries,
                states: yearStates,
                timezones: yearTimezones,
                continents: yearContinents,
                seenGeometry: seenGeometries.first { $0.year == year }
            )
        }.sorted(by: { s1, s2 in s1.year < s2.year })
    }

    func countriesForYear(_ year: Int?) -> [Country] {
        if let year = year {
            return self.countries.filter { $0.years.contains(year) }
        } else {
            return self.countries
        }
    }
    
    func regionsForYear(_ year: Int?) -> [Region] {
        if let year = year {
            return self.states.filter { $0.years.contains(year) }
        } else {
            return self.states
        }
    }
    
    func timezonesForYear(_ year: Int?) -> [Timezone] {
        if let year = year {
            return self.timezones.filter { $0.years.contains(year) }
        } else {
            return self.timezones
        }
    }
    
    func continentsForYear(_ year: Int?) -> [Continent] {
        if let year = year {
            return self.continents.filter { $0.years.contains(year) }
        } else {
            return self.continents
        }
    }
    
    func citiesForYear(_ year: Int?) -> [City] {
        if let year = year {
            return self.cities.filter { $0.years.contains(year) }
        } else {
            return self.cities
        }
    }
    
    func seenGeometryForYear(_ year: Int?) -> SeenGeometry? {
        if let year = year {
            return self.years.first { $0.year == year }?.seenGeometry
        } else {
            return self.seenGeometry
        }
    }
}

func loadTrips() -> [Trip] {
    let filePath = Bundle.main.path(forResource: "visit_periods", ofType: "csv")!
    print("HERE")
    do {
        let csv = try CSV(url: URL(fileURLWithPath: filePath))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return csv.namedRows.enumerated().map { (index, row) in
            Trip(
                id: index,
                since: dateFormatter.date(from: row["since"] ?? "") ?? Date(),
                until: dateFormatter.date(from: row["until"] ?? "") ?? Date(),
                visitedEntityType: VisitPeriodEntityTypes(rawValue: Int16(row["visitedEntityType"] ?? "") ?? 0) ?? .country,
                visitedEntityKey: row["visitedEntityKey"] ?? ""
            )
        }.sorted(by: { t1, t2 in t1.since < t2.since })
    } catch {
        print("Unexpected error: \(error).")
    }
    return []
}
