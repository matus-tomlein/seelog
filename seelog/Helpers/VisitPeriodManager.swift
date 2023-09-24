//
//  VisitPeriodManager.swift
//  Seelog
//
//  Created by Matus Tomlein on 22/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class VisitPeriodManager {
    var visitPeriods: [VisitPeriod]?

    init(context: NSManagedObjectContext) {
        let request = NSFetchRequest<VisitPeriod>(entityName: "VisitPeriod")
        let sortDescriptor = NSSortDescriptor(key: "since", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            self.visitPeriods = try context.fetch(request)
        } catch _ {
            print("Failed to retrieve last year")
        }
    }

    func periodsFor(year: Year, cumulative: Bool, currentTab: SelectedTab, purchasedHistory: Bool) -> [VisitPeriod]? {
        let calendar = NSCalendar.current
        let currentYear = calendar.component(.year, from: Date())

        return visitPeriods?.filter({ period -> Bool in
            let correctCategory = currentTab == .places ||
                (period.type == .country && currentTab == .countries) ||
                (period.type == .timezone && currentTab == .timezones) ||
                (period.type == .continent && currentTab == .continents)

            if correctCategory {
                if let since = period.since, let until = period.until {
                    let sinceYear = calendar.component(.year, from: since)
                    let untilYear = calendar.component(.year, from: until)

                    if !purchasedHistory && max(sinceYear, untilYear) <= currentYear - 2 {
                        return false
                    }

                    if cumulative {
                        return min(sinceYear, untilYear) <= year.year
                    } else {
                        return sinceYear == year.year || untilYear == year.year
                    }
                }
            }

            return false
        })
    }
}
