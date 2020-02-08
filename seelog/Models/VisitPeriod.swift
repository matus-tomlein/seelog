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

extension VisitPeriod: StatsProvider {

    var type: VisitPeriodEntityTypes {
        get {
            return VisitPeriodEntityTypes(rawValue: visitedEntityType) ?? .country
        }
        set {
            visitedEntityType = newValue.rawValue
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
}
