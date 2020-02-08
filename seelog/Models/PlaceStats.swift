//
//  PlaceStats.swift
//  Seelog
//
//  Created by Matus Tomlein on 05/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

protocol TimeSpentStatsProvider: StatsProvider {
    var numDays: Int32 { get }
    var numYears: Int { get }
    func name(geoDB: GeoDatabase) -> String
    func icon(geoDB: GeoDatabase) -> String?
}

extension PlaceStats: TimeSpentStatsProvider {

    var type: VisitPeriodEntityTypes {
        get {
            return VisitPeriodEntityTypes(rawValue: visitedEntityType) ?? .country
        }
        set {
            visitedEntityType = newValue.rawValue
        }
    }

    var numYears: Int {
        get {
            return years?.count ?? 0
        }
    }

    var cityKey: Int64? {
        get {
            return Int64(visitedEntityKey ?? "")
        }
        set {
            if let value = newValue {
                self.visitedEntityKey = String(value)
                self.type = .city
            }
        }
    }

    static func findBy(visitedEntityType: VisitPeriodEntityTypes, visitedEntityKey: String, context: NSManagedObjectContext) -> PlaceStats? {
        do {
            let request = NSFetchRequest<PlaceStats>(entityName: "PlaceStats")
            request.predicate = NSPredicate(format: "visitedEntityType = %d AND visitedEntityKey = %@", visitedEntityType.rawValue, visitedEntityKey)
            request.fetchLimit = 1
            return try context.fetch(request).first
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return nil
    }

    func update(visitPeriod: VisitPeriod) {
        guard let visitPeriodSince = visitPeriod.since else { return }
        guard let visitPeriodUntil = visitPeriod.until else { return }
        guard let visitPeriodSinceYearDay = Helpers.yearDay(date: visitPeriodSince) else { return }
        guard let visitPeriodUntilYearDay = Helpers.yearDay(date: visitPeriodUntil) else { return }

        self.lastDate = visitPeriodUntil
        if visitPeriodUntilYearDay <= lastYearDay { return }

        if self.firstDate == nil {
            self.firstDate = visitPeriod.since
            self.firstYearDay = visitPeriodSinceYearDay
        }

        let days = Helpers.daysInRange(startDate: visitPeriodSince, endDate: visitPeriodUntil)
        var years: Set<Int16> = Set(self.years ?? [])
        var months: Set<Int16> = Set(self.months ?? [])
        for day in days {
            if let yearDay = Helpers.yearDay(date: day) {
                if yearDay > lastYearDay {
                    self.numDays += 1
                    lastYearDay = yearDay
                    years.insert(Helpers.year(date: day))
                    months.insert(Helpers.month(date: day))
                }
            }
        }
        self.years = Array(years)
        self.months = Array(months)
    }
}
