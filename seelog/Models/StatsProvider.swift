//
//  StatsProvider.swift
//  Seelog
//
//  Created by Matus Tomlein on 27/10/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation

protocol StatsProvider {
    var visitedEntityKey: String? { get set }
    var visitedEntityType: Int16 { get set }
    var type: VisitPeriodEntityTypes { get set }
    var cityKey: Int64? { get set }
    var timezoneId: Int32? { get set }
    func countryInfo(geoDB: GeoDatabase) -> CountryInfo?
    func stateInfo(geoDB: GeoDatabase) -> StateInfo?
    func cityInfo(geoDB: GeoDatabase) -> CityInfo?
    func timezoneInfo(geoDB: GeoDatabase) -> TimezoneInfo?
    func continentInfo(geoDB: GeoDatabase) -> ContinentInfo?
    func name(geoDB: GeoDatabase) -> String
    func icon(geoDB: GeoDatabase) -> String?
}

extension StatsProvider {
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
