//
//  Year.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

extension Year {
    static func last(context: NSManagedObjectContext) -> Year? {
        let request = NSFetchRequest<Year>(entityName: "Year")
        request.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "year", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            return try context.fetch(request).first
        } catch _ {
            print("Failed to retrieve last year")
        }

        return nil
    }

    var name: String {
        get { return String(year) }
    }

    func chartValue(selectedTab: SelectedTab, cumulative: Bool, geoDB: GeoDatabase) -> Double {
        switch selectedTab {
        case .countries:
            return Double(numberOfCountries(cumulative: cumulative))

        case .cities:
            return Double(numberOfCities(cumulative: cumulative))

        case .places:
            return Double(seenArea(cumulative: cumulative))

        case .states:
            return Double(numberOfStates(cumulative: cumulative))

        case .continents:
            return Double(numberOfContinents(cumulative: cumulative))

        case .timezones:
            return Double(numberOfTimezones(cumulative: cumulative, geoDB: geoDB))
        }
    }

    func numberOfCountries(cumulative: Bool) -> Int {
        return cumulative ? cumulativeCountries?.count ?? 0 : countries?.count ?? 0
    }

    func numberOfCities(cumulative: Bool) -> Int {
        return cumulative ? cumulativeCities?.count ?? 0 : cities?.count ?? 0
    }

    func seenArea(cumulative: Bool) -> Int {
        return Int(round(cumulative ? cumulativeSeenArea : seenArea))
    }

    func numberOfStates(cumulative: Bool) -> Int {
        return cumulative ? countStates(countriesAndStates: cumulativeCountries ?? [:]) : countStates(countriesAndStates: countries ?? [:])
    }

    func numberOfContinents(cumulative: Bool) -> Int {
        return continents(cumulative: cumulative)?.count ?? 0
    }

    func numberOfTimezones(cumulative: Bool, geoDB: GeoDatabase) -> Int {
        return timezones(cumulative: cumulative, geoDB: geoDB)?.count ?? 0
    }

    func chartLabel(selectedTab: SelectedTab, cumulative: Bool, geoDB: GeoDatabase) -> String {
        let value = chartValue(selectedTab: selectedTab, cumulative: cumulative, geoDB: geoDB)
        if selectedTab == .places {
            if value > 1000 {
                return String(Int(round(value / 1000))) + "k"
            } else {
                return String(Int(round(value)))
            }
        } else {
            return String(Int(value))
        }
    }

    func countries(cumulative: Bool) -> [String: [String]]? {
        return cumulative ? cumulativeCountries : countries
    }

    func countries(cumulative: Bool, geoDB: GeoDatabase) -> [CountryInfo]? {
        return countries(cumulative: cumulative)?.keys.map({ geoDB.countryInfoFor(countryKey: $0) }).filter({ $0 != nil }).map({ $0! }).sorted { $0.name < $1.name }
    }

    func cities(cumulative: Bool) -> [Int64]? {
        return cumulative ? cumulativeCities : cities
    }

    func cityInfos(cumulative: Bool, geoDB: GeoDatabase) -> [CityInfo]? {
        return cities(cumulative: cumulative)?.map({ geoDB.cityInfoFor(cityKey: $0) }) .filter({ $0 != nil }).map({ $0! })
    }

    func geohashes(cumulative: Bool) -> [String]? {
        return cumulative ? cumulativeGeohashes : geohashes
    }

    func continents(cumulative: Bool) -> [String]? {
        return cumulative ? cumulativeContinents : continents
    }

    func continentInfos(cumulative: Bool, geoDB: GeoDatabase) -> [ContinentInfo]? {
        if let continents = continents(cumulative: cumulative) {
            return continents.map({ geoDB.continentInfoFor(name: $0) }).filter({ $0 != nil }).map({ $0! })
        }
        return nil
    }

    func processedHeatmapWKT(cumulative: Bool) -> String? {
        return cumulative ? cumulativeProcessedHeatmapWKT?.wkt : processedHeatmapWKT?.wkt
    }

    func landWKT(cumulative: Bool) -> String? {
        return cumulative ? cumulativeLandWKT?.wkt : landWKT?.wkt
    }

    func waterWKT(cumulative: Bool) -> String? {
        managedObjectContext?.refresh(self, mergeChanges: true)
        return cumulative ? cumulativeWaterWKT?.wkt : waterWKT?.wkt
    }

    func timezones(cumulative: Bool, geoDB: GeoDatabase) -> [TimezoneInfo]? {
        if cumulative {
            return cumulativeTimezones?.map({ geoDB.timezoneInfoFor(timezoneId: $0)}).filter({ $0 != nil }).map({ $0! })
        } else {
            return timezones?.map({ geoDB.timezoneInfoFor(timezoneId: $0)}).filter({ $0 != nil }).map({ $0! })
        }
    }

    func timezoneNames(cumulative: Bool, geoDB: GeoDatabase) -> [String]? {
        if let names = timezones(cumulative: cumulative, geoDB: geoDB)?.map({ $0.name }) {
            return Array(Set(names)).sorted { (Int($0) ?? 0) < (Int($1) ?? 0) }
        }
        return nil
    }

    func regions(cumulative: Bool, geoDB: GeoDatabase) -> [String: [String]]? {
        if let countries = countries(cumulative: cumulative, geoDB: geoDB) {
            var regions = [String: [String]]()
            for country in countries {
                if var subregions = regions[country.region] {
                    if !subregions.contains(country.subregion) {
                        subregions.append(country.subregion)
                        regions[country.region] = subregions
                    }
                } else {
                    regions[country.region] = [country.subregion]
                }
            }
            return regions
        }
        return nil
    }

    func countStates(countriesAndStates: [String: [String]]) -> Int {
        var count = 0
        for country in countriesAndStates.keys {
            if let c = countriesAndStates[country]?.count { count += c }
        }
        return count
    }
}
