//
//  PlaceStatsManager.swift
//  Seelog
//
//  Created by Matus Tomlein on 06/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class PlaceStatsManager {
    var placeStats: [PlaceStats]?

    init(context: NSManagedObjectContext) {
        let request = NSFetchRequest<PlaceStats>(entityName: "PlaceStats")
        let sortDescriptor = NSSortDescriptor(key: "numDays", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            self.placeStats = try context.fetch(request)
        } catch _ {
            print("Failed to retrieve last year")
        }
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
