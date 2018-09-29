//
//  MonthStatsUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class MonthStatsUpdater {
    var countriesForMonths = [String: [String]]()

    func processNewPhoto(photo: Photo) {
        if let countryKey = photo.countryKey, let month = photo.month {
            if let countries = countriesForMonths[month] {
                if !countries.contains(countryKey) {
                    countriesForMonths[month] = countries + [countryKey]
                }
            } else {
                countriesForMonths[month] = [countryKey]
            }
        }
    }

    func update(context: NSManagedObjectContext) {
        updateCountries(context: context)
    }

    private func updateCountries(context: NSManagedObjectContext) {
        for month in countriesForMonths.keys {
            let countries = countriesForMonths[month]!

            let request = NSFetchRequest<Month>(entityName: "Month")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "month == %@", month)

            do {
                let models = try context.fetch(request)
                if let model = models.first,
                    let oldCountries = model.countries {
                    let newCountries = Helpers.combineIntoUniqueList(oldCountries, countries)
                    model.countries = newCountries
                } else {
                    let model = Month(context: context)
                    model.month = month
                    model.countries = countries
                }
            } catch {
                print("Failed to fetch months.")
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save months.")
        }
    }
}
