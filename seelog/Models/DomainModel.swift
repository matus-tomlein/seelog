//
//  DomainModel.swift
//  seelog
//
//  Created by Matus Tomlein on 12/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import SwiftCSV

struct Trip {
    var since: Date
    var until: Date
    var visitedEntityType: VisitPeriodEntityTypes
    var visitedEntityKey: String
}

struct Country: Identifiable {
    var id: String { get { return countryInfo.countryKey } }
    var countryInfo: CountryInfo
    var trips: [Trip]
}

struct YearStats: Identifiable {
    var id: Int { get { return year } }
    var year: Int
    var countries: [Country]
}

class DomainModel {
    var trips: [Trip]
    var countries: [Country]
    var years: [YearStats] = []
    var geoDatabase: GeoDatabase
    var countryYearCounts: [(year: Int, count: Int)] {
        get { return years.reversed().map { year in (year: year.year, count: year.countries.count) } }
    }

    init(trips: [Trip], geoDatabase: GeoDatabase) {
        self.trips = trips
        self.geoDatabase = geoDatabase

        self.countries = Dictionary(grouping: trips.filter { $0.visitedEntityType == .country }, by: { $0.visitedEntityKey })
            .map { key, value in (geoDatabase.countryInfoFor(countryKey: key), value) }
            .filter { $0.0 != nil }
            .map { Country(countryInfo: $0.0!, trips: $0.1) }
            .sorted(by: { $0.countryInfo.name < $1.countryInfo.name })
        
        var years = Set(trips.flatMap { trip in Array(trip.since.year()...trip.until.year()) })
        years.insert(Date().year())
        self.years = years.map { year in
            YearStats(
                year: year,
                countries: countries.filter { country in
                    !country.trips.filter { trip in year >= trip.since.year() && year <= trip.until.year() }.isEmpty
                }
            )
        }.sorted(by: { s1, s2 in s1.year < s2.year })
    }
}

func loadTrips() -> [Trip] {
    let filePath = Bundle.main.path(forResource: "visit_periods", ofType: "csv")!
    print("HERE")
    do {
        let csv = try CSV(url: URL(fileURLWithPath: filePath))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return csv.namedRows.map { row in
            Trip(
                since: dateFormatter.date(from: row["since"] ?? "") ?? Date(),
                until: dateFormatter.date(from: row["until"] ?? "") ?? Date(),
                visitedEntityType: VisitPeriodEntityTypes(rawValue: Int16(row["visitedEntityType"] ?? "") ?? 0) ?? .country,
                visitedEntityKey: row["visitedEntityKey"] ?? ""
            )
        }
    } catch {
        print("Unexpected error: \(error).")
    }
    return []
}
