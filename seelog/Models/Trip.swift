//
//  Trip.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Trip: Identifiable {
    var id: Int
    var since: Date
    var until: Date
    var visitedEntityType: VisitPeriodEntityTypes
    var visitedEntityKey: String
    var years: [Int]

    func formatDateInterval() -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: since, to: until)
    }
}

extension Trip {
    init(id: Int, since: Date, until: Date, visitedEntityType: VisitPeriodEntityTypes, visitedEntityKey: String) {
        self.id = id
        self.since = since
        self.until = until
        self.visitedEntityKey = visitedEntityKey
        self.visitedEntityType = visitedEntityType
        self.years = Array(since.year()...until.year())
    }
    
    func months(year: Int) -> [Int] {
        let calendar = Calendar.current
        let since = firstDayInYear(year)
        let until = lastDayInYear(year)
        let monthSince = calendar.component(.month, from: since)
        let monthUntil = calendar.component(.month, from: until)
        return Array(monthSince...monthUntil)
    }
    
    func firstDayInYear(_ year: Int) -> Date {
        let calendar = Calendar.current
        if let firstOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) {
            return max(firstOfYear, calendar.startOfDay(for: self.since))
        }
        return calendar.startOfDay(for: self.since)
    }
    
    func lastDayInYear(_ year: Int) -> Date {
        let calendar = Calendar.current
        if let firstOfNextYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)),
            let lastOfYear = calendar.date(byAdding: .day, value: -1, to: firstOfNextYear) {
            return min(lastOfYear, calendar.startOfDay(for: self.until))
        }
        return calendar.startOfDay(for: self.until)
    }
    
    static func extractTripsInfo(trips: [Trip]) -> (tripsByYear: [Int: [Trip]], stayDuration: Int, stayDurationByYear: [Int: Int], years: [Int]) {
        let tripsByYear = Dictionary(
            grouping: trips.flatMap { trip in trip.years.map { year in (trip, year) } },
            by: { trip, year in year }
        ).mapValues { trips in trips.map { $0.0 }}
        let stayDurationByYear = Dictionary(
            uniqueKeysWithValues: tripsByYear.map { (year, trips) in
                (
                    year,
                    Set(trips.flatMap { trip in
                        Date.dates(from: trip.firstDayInYear(year), to: trip.lastDayInYear(year))
                    }).count
                )
            }
        )
        let stayDuration = stayDurationByYear.values.reduce(0, +)
        let years = stayDurationByYear.keys.sorted()

        return (
            tripsByYear: tripsByYear,
            stayDuration: stayDuration,
            stayDurationByYear: stayDurationByYear,
            years: years
        )
    }
}
