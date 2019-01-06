//
//  PlaceStats.swift
//  Seelog
//
//  Created by Matus Tomlein on 05/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

extension PlaceStats {
    var type: VisitPeriodEntityTypes {
        get {
            return VisitPeriodEntityTypes(rawValue: visitedEntityType) ?? .country
        }
        set {
            visitedEntityType = newValue.rawValue
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

    var timezoneId: Int32? {
        get {
            return Int32(visitedEntityKey ?? "")
        }
        set {
            if let value = newValue {
                self.visitedEntityKey = String(value)
                self.type = .timezone
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

        if Helpers.yearDay(date: visitPeriodUntil) <= lastYearDay { return }

        if self.firstDate == nil {
            self.firstDate = visitPeriod.since
            self.firstYearDay = Helpers.yearDay(date: visitPeriodSince)
        }
        self.lastDate = visitPeriodUntil

        let days = Helpers.daysInRange(startDate: visitPeriodSince, endDate: visitPeriodUntil)
        for day in days {
            let yearDay = Helpers.yearDay(date: day)
            if yearDay > lastYearDay {
                self.numDays += 1
                lastYearDay = yearDay
            }
        }

        var newYears = Helpers.yearsInRange(startDate: visitPeriodSince, endDate: visitPeriodUntil)
        if let existingYears = self.years {
            newYears = Array(Set(existingYears + newYears))
        }
        self.years = newYears

        var newMonths = Helpers.monthsInRange(startDate: visitPeriodSince, endDate: visitPeriodUntil)
        if let existingMonths = self.months {
            newMonths = Array(Set(existingMonths + newMonths))
        }
        self.months = newMonths
    }

    func countryInfo(geoDB: GeoDatabase) -> CountryInfo? {
        if type == .country {
            guard let visitedEntityKey = self.visitedEntityKey else { return nil }
            return geoDB.countryInfoFor(countryKey: visitedEntityKey)
        }
        return nil
    }

    func stateInfo(geoDB: GeoDatabase) -> StateInfo? {
        if type == .state {
            guard let visitedEntityKey = self.visitedEntityKey else { return nil }
            return geoDB.stateInfoFor(stateKey: visitedEntityKey)
        }
        return nil
    }

    func cityInfo(geoDB: GeoDatabase) -> CityInfo? {
        if type == .city {
            guard let cityKey = self.cityKey else { return nil }
            return geoDB.cityInfoFor(cityKey: cityKey)
        }
        return nil
    }

    func timezoneInfo(geoDB: GeoDatabase) -> TimezoneInfo? {
        if type == .timezone {
            guard let timezoneId = self.timezoneId else { return nil }
            return geoDB.timezoneInfoFor(timezoneId: timezoneId)
        }
        return nil
    }

    func continentInfo(geoDB: GeoDatabase) -> ContinentInfo? {
        if type == .continent {
            guard let visitedEntityKey = self.visitedEntityKey else { return nil }
            return geoDB.continentInfoFor(name: visitedEntityKey)
        }
        return nil
    }

    func name(geoDB: GeoDatabase) -> String {
        if let countryInfo = countryInfo(geoDB: geoDB) {
            return countryInfo.name
        } else if let stateInfo = stateInfo(geoDB: geoDB) {
            return stateInfo.name
        } else if let cityInfo = cityInfo(geoDB: geoDB) {
            return cityInfo.name
        } else if let timezoneInfo = timezoneInfo(geoDB: geoDB) {
            return timezoneInfo.name
        } else if let continentInfo = continentInfo(geoDB: geoDB) {
            return continentInfo.name
        }

        return ""
    }

    func icon(geoDB: GeoDatabase) -> String? {
        if let countryInfo = countryInfo(geoDB: geoDB) {
            return Helpers.flag(country: countryInfo.countryKey)
        } else if let stateInfo = stateInfo(geoDB: geoDB) {
            return Helpers.flag(country: stateInfo.countryKey)
        } else if let cityInfo = cityInfo(geoDB: geoDB) {
            return Helpers.flag(country: cityInfo.countryKey)
        }
        return nil
    }
}
