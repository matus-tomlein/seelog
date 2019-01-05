//
//  VisitPeriod.swift
//  Seelog
//
//  Created by Matus Tomlein on 17/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

enum VisitPeriodEntityTypes: Int16 {
    case country = 0
    case state = 1
    case city = 2
    case timezone = 3
    case continent = 4
}

extension VisitPeriod {
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

    var open: Bool { get { return !closed } }

    func processNewPhoto(photoInfo: PhotoInfo) {
        var updateUntil = true
        switch type {
        case .city:
            if photoInfo.cities.count > 0 {
                if let cityKey = self.cityKey {
                    self.closed = !photoInfo.cities.contains(cityKey)
                }
            } else {
                if let geoDB = photoInfo.geoDB,
                    let cityInfo = cityInfo(geoDB: geoDB) {
                    let cityLocation = CLLocation(
                        latitude: cityInfo.latitude,
                        longitude: cityInfo.longitude)
                    let photoLocation = CLLocation(
                        latitude: photoInfo.latitude,
                        longitude: photoInfo.longitude)

                    let distance = cityLocation.distance(from: photoLocation)

                    if distance > 50 * 1000 { // 50 km
                        self.closed = true
                    }
                }
                updateUntil = false
            }

        case .continent:
            self.closed = photoInfo.continent != self.visitedEntityKey

        case .country:
            self.closed = photoInfo.countryKey != self.visitedEntityKey

        case .state:
            self.closed = photoInfo.stateKey != self.visitedEntityKey

        case .timezone:
            self.closed = photoInfo.timezone != self.timezoneId
        }

        if self.open && updateUntil {
            self.until = photoInfo.creationDate
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
