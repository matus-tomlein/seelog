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
    private var countriesById: [String: Country] = [:]
    private var statesById: [String: Region] = [:]
    private var timezonesById: [Int32: Timezone] = [:]
    private var continentsById: [String: Continent] = [:]
    private var citiesById: [Int64: City] = [:]

    var countries: [Country] { return countriesById.values.sorted(by: { $0.countryInfo.name < $1.countryInfo.name }) }
    var states: [Region] { return statesById.values.sorted(by: { $0.stateInfo.name < $1.stateInfo.name }) }
    var timezones: [Timezone] { return timezonesById.values.sorted(by: { $0.timezoneInfo.name < $1.timezoneInfo.name }) }
    var continents: [Continent] { return continentsById.values.sorted(by: { $0.continentInfo.name < $1.continentInfo.name }) }
    var cities: [City] { return citiesById.values.sorted(by: { $0.cityInfo.name < $1.cityInfo.name }) }

    var continentInfos: [ContinentInfo] = []
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

        for (type, tripsByPlace) in tripsByType {
            for (entityKey, trips) in tripsByPlace {
                switch type {
                case .country:
                    if let countryInfo = geoDatabase.countryInfoFor(countryKey: entityKey) {
                        let country = Country(countryInfo: countryInfo, trips: trips, model: self)
                        self.countriesById[country.id] = country
                    }
                    
                case .state:
                    if let stateInfo = geoDatabase.stateInfoFor(stateKey: entityKey) {
                        let region = Region(stateInfo: stateInfo, trips: trips, model: self)
                        self.statesById[region.id] = region
                    }
                    
                case .timezone:
                    if let timezoneId = Int32(entityKey),
                        let timezoneInfo = geoDatabase.timezoneInfoFor(timezoneId: timezoneId) {
                        let timezone = Timezone(timezoneInfo: timezoneInfo, trips: trips)
                        self.timezonesById[timezone.id] = timezone
                    }

                case .city:
                    if let cityKey = Int64(entityKey),
                        let cityInfo = geoDatabase.cityInfoFor(cityKey: cityKey) {
                        let city = City(cityInfo: cityInfo, trips: trips, model: self)
                        self.citiesById[city.id] = city
                        if let stateKey = cityInfo.stateKey {
                            if self.statesById[stateKey] == nil {
                                if let stateInfo = geoDatabase.stateInfoFor(stateKey: stateKey) {
                                    let region = Region(stateInfo: stateInfo, trips: trips, model: self)
                                    self.statesById[region.id] = region
                                }
                            }
                        }
                    }

                case .continent:
                    if let continentInfo = geoDatabase.continentInfoFor(name: entityKey) {
                        let continent = Continent(continentInfo: continentInfo, trips: trips, model: self)
                        self.continentsById[continent.id] = continent
                    }
                }
            }
        }

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
            let seenGeometry = seenGeometries.filter { $0.year == year }.first

            return Year(
                year: year,
                cities: yearCities,
                countries: yearCountries,
                states: yearStates,
                timezones: yearTimezones,
                continents: yearContinents,
                seenGeometry: seenGeometry
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
            return self.cities.filter { $0.visited(year: year) }
        } else {
            return self.cities
        }
    }

    func citiesNotVisited(_ year: Int?) -> [City] {
        if let year = year {
            return self.cities.filter { !$0.visited(year: year) }
        } else {
            return []
        }
    }

    func seenGeometry(year: Int?) -> SeenGeometry? {
        if let year = year {
            return self.years.first { $0.year == year }?.seenGeometry
        } else {
            return self.seenGeometry
        }
    }

    func countries(year: Int?, explorationStatus: ExplorationStatus) -> [Country] {
        return countriesForYear(year).filter { $0.explorationStatusForYear(year) == explorationStatus }
    }

    func countries(year: Int?, stayDurationStatus: StayDurationStatus) -> [Country] {
        return countriesForYear(year).filter { $0.stayDurationStatusForYear(year) == stayDurationStatus }
    }
    
    func countriesByExplorationStatus(year: Int?) -> [(status: ExplorationStatus, countries: [Country])] {
        let dict = Dictionary(grouping: countriesForYear(year), by: { $0.explorationStatusForYear(year) })
        return [
            ExplorationStatus.conqueror, ExplorationStatus.explorer
        ].map { status in
            if let countries = dict[status] {
                return (status: status, countries: countries)
            } else {
                return (status: status, countries: [])
            }
        }.filter { $0.countries.count > 0 }
    }
    
    func countriesByStayDurationStatus(year: Int?) -> [(status: StayDurationStatus, countries: [Country])] {
        let dict = Dictionary(grouping: countriesForYear(year), by: { $0.stayDurationStatusForYear(year) })
        return [
            StayDurationStatus.native, StayDurationStatus.tourist
        ].map { status in
            if let countries = dict[status] {
                return (status: status, countries: countries)
            } else {
                return (status: status, countries: [])
            }
        }.filter { $0.countries.count > 0 }
    }
    
    func continents(year: Int?, explorationStatus: ExplorationStatus) -> [Continent] {
        return continentsForYear(year).filter { $0.explorationStatusForYear(year) == explorationStatus }
    }
    
    func continents(year: Int?, stayDurationStatus: StayDurationStatus) -> [Continent] {
        return continentsForYear(year).filter { $0.stayDurationStatusForYear(year) == stayDurationStatus }
    }
    
    func continentsByExplorationStatus(year: Int?) -> [(status: ExplorationStatus, continents: [Continent])] {
        let dict = Dictionary(grouping: continentsForYear(year), by: { $0.explorationStatusForYear(year) })
        return [
            ExplorationStatus.conqueror, ExplorationStatus.explorer, ExplorationStatus.visitor
        ].map { status in
            if let continents = dict[status] {
                return (status: status, continents: continents)
            } else {
                return (status: status, continents: [])
            }
        }.filter { $0.continents.count > 0 }
    }

    func continentsByStayDurationStatus(year: Int?) -> [(status: StayDurationStatus, continents: [Continent])] {
        let dict = Dictionary(grouping: continentsForYear(year), by: { $0.stayDurationStatusForYear(year) })
        return [
            StayDurationStatus.native, StayDurationStatus.tourist
        ].map { status in
            if let continents = dict[status] {
                return (status: status, continents: continents)
            } else {
                return (status: status, continents: [])
            }
        }.filter { $0.continents.count > 0 }
    }
    
    func region(id: String) -> Region { return self.statesById[id]! }
    func country(id: String) -> Country { return self.countriesById[id]! }
    func city(id: Int64) -> City { return self.citiesById[id]! }
    func timezone(id: Int32) -> Timezone { return self.timezonesById[id]! }
    func continent(id: String) -> Continent { return self.continentsById[id]! }
    
    func positions(year: Int?, minLatitude: Double, maxLatitude: Double, minLongitude: Double, maxLongitude: Double) -> [Location] {
        let xs = [
            Helpers.longitudeToX(minLongitude),
            Helpers.longitudeToX(maxLongitude)
        ].sorted()
        let minX = xs.first!
        let maxX = xs.last!
        let ys = [
            Helpers.latitudeToY(minLatitude),
            Helpers.latitudeToY(maxLatitude)
        ].sorted()
        let minY = ys.first!
        let maxY = ys.last!
        let positions = self.seenGeometry(year: year)?.positions ?? []
        return positions.filter { position in
            position.x >= minX && position.x <= maxX &&
                position.y >= minY && position.y <= maxY
        }
    }
}

func loadTrips() -> [Trip] {
    let filePath = Bundle.main.path(forResource: "visit_periods", ofType: "csv")!
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

func loadSeenGeometries() -> [SeenGeometry] {
    let filePath = Bundle.main.path(forResource: "seen_areas", ofType: "csv")!
    do {
        let csv = try CSV(url: URL(fileURLWithPath: filePath))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return csv.namedRows.enumerated().map { (index, row) in
            SeenGeometry(
                year: Int(row["ZYEAR"] ?? ""),
                geohashes: Set(),
                travelledDistance: Double(row["ZTRAVELLEDDISTANCE"] ?? "") ?? 0,
                landWKT: row["ZLANDWKT"] ?? "",
                waterWKT: row["ZWATERWKT"] ?? "",
                processedWKT: row["ZPROCESSEDHEATMAPWKT"] ?? ""
            )
        }
    } catch {
        print("Unexpected error: \(error).")
    }
    return []
}

func simulatedDomainModel() -> DomainModel {
    return DomainModel(trips: loadTrips(), seenGeometries: loadSeenGeometries(), geoDatabase: GeoDatabase())
}
