//
//  VisitPeriodUpdater.swift
//  Seelog
//
//  Created by Matus Tomlein on 17/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class VisitPeriodUpdater {
    var context: NSManagedObjectContext
    var openPeriods: [VisitPeriod] = []

    init(context: NSManagedObjectContext) {
        self.context = context

        do {
            let request = NSFetchRequest<VisitPeriod>(entityName: "VisitPeriod")
            request.predicate = NSPredicate(format: "closed = false")
            openPeriods = try context.fetch(request)
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }

    func processNewPhoto(photoInfo: PhotoInfo) {
        for period in openPeriods {
            period.processNewPhoto(photoInfo: photoInfo)
        }
        openPeriods = openPeriods.filter({ $0.open })

        if let countryKey = photoInfo.countryKey {
            let existing = openPeriods.filter({ $0.type == .country && $0.visitedEntityKey == countryKey })
            if existing.count == 0 {
                let period = initializeOpenPeriod(photoInfo: photoInfo)
                period.visitedEntityKey = countryKey
                period.type = .country
                openPeriods.append(period)
            }
        }

        if let stateKey = photoInfo.stateKey {
            let existing = openPeriods.filter({ $0.type == .state && $0.visitedEntityKey == stateKey })
            if existing.count == 0 {
                let period = initializeOpenPeriod(photoInfo: photoInfo)
                period.visitedEntityKey = stateKey
                period.type = .state
                openPeriods.append(period)
            }
        }

        for cityKey in photoInfo.cities {
            let existing = openPeriods.filter({ $0.type == .city && $0.cityKey == cityKey })
            if existing.count == 0 {
                var period = initializeOpenPeriod(photoInfo: photoInfo)
                period.cityKey = cityKey
                period.type = .city
                openPeriods.append(period)
            }
        }

        if let continent = photoInfo.continent {
            let existing = openPeriods.filter({ $0.type == .continent && $0.visitedEntityKey == continent })
            if existing.count == 0 {
                let period = initializeOpenPeriod(photoInfo: photoInfo)
                period.visitedEntityKey = continent
                period.type = .continent
                openPeriods.append(period)
            }
        }

        if let timezone = photoInfo.timezone {
            let existing = openPeriods.filter({ $0.type == .timezone && $0.timezoneId == timezone })
            if existing.count == 0 {
                var period = initializeOpenPeriod(photoInfo: photoInfo)
                period.timezoneId = timezone
                period.type = .timezone
                openPeriods.append(period)
            }
        }
    }

    private func initializeOpenPeriod(photoInfo: PhotoInfo) -> VisitPeriod {
        let period = VisitPeriod(context: self.context)
        period.since = photoInfo.creationDate
        period.until = photoInfo.creationDate
        period.closed = false
        return period
    }
}
