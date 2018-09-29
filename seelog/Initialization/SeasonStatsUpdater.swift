//
//  SeasonStatsUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class SeasonStatsUpdater {
    var countriesForSeasons = [String: [String]]()
    
    func processNewPhoto(photo: Photo) {
        if let season = photo.season,
            let countryKey = photo.countryKey {
            if let countries = countriesForSeasons[season] {
                if !countries.contains(countryKey) {
                    countriesForSeasons[season] = countries + [countryKey]
                }
            } else {
                countriesForSeasons[season] = [countryKey]
            }
        }
    }

    func update(context: NSManagedObjectContext) {
        for season in countriesForSeasons.keys {
            let countries = countriesForSeasons[season]!

            let request = NSFetchRequest<Season>(entityName: "Season")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "season == %@", season)

            do {
                let models = try context.fetch(request)
                if let model = models.first,
                    let oldCountries = model.countries {
                    let newCountries = Helpers.combineIntoUniqueList(oldCountries, countries)
                    model.countries = newCountries
                } else {
                    let model = Season(context: context)
                    model.season = season
                    model.countries = countries
                }
            } catch {
                print("Failed to fetch seasons.")
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save seasons.")
        }
    }
}
