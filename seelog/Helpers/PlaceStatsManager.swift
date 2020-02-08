//
//  PlaceStatsManager.swift
//  Seelog
//
//  Created by Matus Tomlein on 06/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

struct TimeSpentStat: TimeSpentStatsProvider {
    var numDays: Int32
    var numYears: Int
    var visitedEntityKey: String?
    var visitedEntityType: Int16
}

class PlaceStatsManager {
    var placeStats: [PlaceStats]?
    var visitPeriodManager: VisitPeriodManager

    init(context: NSManagedObjectContext, visitPeriodManager: VisitPeriodManager) {
        self.visitPeriodManager = visitPeriodManager
        let request = NSFetchRequest<PlaceStats>(entityName: "PlaceStats")
        let sortDescriptor = NSSortDescriptor(key: "numDays", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            self.placeStats = try context.fetch(request)
        } catch _ {
            print("Failed to retrieve last year")
        }
    }

    func placeStatsFor(year: Year, cumulative: Bool, currentTab: SelectedTab, purchasedHistory: Bool) -> [TimeSpentStatsProvider]? {
        if cumulative {
            return placeStatsFor(currentTab: currentTab)
        } else {
            if let visitPeriods = visitPeriodManager.periodsFor(year: year, cumulative: cumulative, currentTab: currentTab, purchasedHistory: purchasedHistory) {

                let byEntities = Dictionary(grouping: visitPeriods, by: { $0.visitedEntityType })
                let placeStats = byEntities.map({ (entityType, periods) -> [TimeSpentStatsProvider] in
                    return Dictionary(grouping: periods, by: { $0.visitedEntityKey }).mapValues { periods in
                        return periods.flatMap { period in
                            Date.dates(from: period.since!, to: period.until!).filter { date in
                                date.year() == year.year
                            }
                        }
                    }.map { (entityKey, dates) in
                        return (entityKey, Set(dates))
                    }.map { (entityKey, dates) -> TimeSpentStatsProvider in
                        let placeStats = TimeSpentStat(
                            numDays: Int32(dates.count),
                            numYears: 1,
                            visitedEntityKey: entityKey,
                            visitedEntityType: entityType)
                        return placeStats
                    }
                }).flatMap( { $0 })

                return placeStats.sorted(by: { $0.numDays > $1.numDays })
            }
        }
        return nil
    }

    func placeStatsFor(currentTab: SelectedTab) -> [PlaceStats]? {
        return placeStats?.filter({ placeStats -> Bool in
            let correctCategory = currentTab == .places ||
                (placeStats.type == .country && currentTab == .countries) ||
                (placeStats.type == .state && currentTab == .states) ||
                (placeStats.type == .city && currentTab == .cities) ||
                (placeStats.type == .timezone && currentTab == .timezones) ||
                (placeStats.type == .continent && currentTab == .continents)

            return correctCategory
        })
    }
}
