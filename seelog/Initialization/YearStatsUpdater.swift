//
//  CountriesStatsUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class YearStatsUpdater {

    var countriesForYears = [Int32: [String]]()

    func processNewPhoto(photo: Photo) {
        if let countryKey = photo.countryKey,
            let year = photo.year {

            if let countries = countriesForYears[year] {
                if !countries.contains(countryKey) {
                    countriesForYears[year] = countries + [countryKey]
                }
            } else {
                countriesForYears[year] = [countryKey]
            }
        }
    }

    func update(context: NSManagedObjectContext) {
        updateCountries(context: context)
    }

    private func updateCountries(context: NSManagedObjectContext) {
        for year in countriesForYears.keys {
            let countries = countriesForYears[year]!

            let request = NSFetchRequest<Year>(entityName: "Year")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "year == %@", NSNumber(value: year))

            do {
                let years = try context.fetch(request)
                if let model = years.first {
                    var newCountries: [String] = []
                    for country in countries {
                        if !(model.countries?.contains(country) ?? false) {
                            newCountries.append(country)
                        }
                    }
                    if newCountries.count > 0 {
                        model.countries = (model.countries ?? []) + newCountries
                        try context.save()
                    }
                } else {
                    let model = Year(context: context)
                    model.year = Int32(year)
                    model.countries = countries
                    try context.save()
                }
            } catch {
                print("Failed to fetch years.")
            }
        }
    }

}
