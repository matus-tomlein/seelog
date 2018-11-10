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

    func chartValue(selectedTab: SelectedTab, cumulative: Bool) -> Double {
        switch selectedTab {
        case .countries:
            return cumulative ? Double(cumulativeCountries?.count ?? 0) : Double(countries?.count ?? 0)

        case .cities:
            return cumulative ? Double(cumulativeCities?.count ?? 0) : Double(cities?.count ?? 0)

        case .places:
            return cumulative ? cumulativeSeenArea : seenArea
        }
    }

    func chartLabel(selectedTab: SelectedTab, cumulative: Bool) -> String {
        let value = chartValue(selectedTab: selectedTab, cumulative: cumulative)
        if selectedTab == .countries {
            return String(Int(value))
        } else {
            if value > 1000 {
                return String(Int(round(value / 1000))) + "k"
            } else {
                return String(Int(round(value)))
            }
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

    func geohashes(cumulative: Bool) -> [String]? {
        return cumulative ? cumulativeGeohashes : geohashes
    }

    func continents(cumulative: Bool, geoDB: GeoDatabase) -> [String]? {
        if let countries = countries(cumulative: cumulative, geoDB: geoDB) {
            return Array(Set(countries.map({ $0.continent }))).sorted()
        }
        return nil
    }

    func heatmapWKT(cumulative: Bool) -> String? {
        return cumulative ? cumulativeHeatmapWKTProcessed : heatmapWKTProcessed
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
}
