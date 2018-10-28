//
//  VisitedPlacesStats.swift
//  seelog
//
//  Created by Matus Tomlein on 01/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class VisitedPlacesStats {
    var countryStates = [String: [String]]()
    var heatmapSquares = [String: Int64]()
    var cities = [Int64]()

    func processNewPhoto(photo: Photo) {
        if let countryKey = photo.countryKey {
            if var states = countryStates[countryKey] {
                if let stateKey = photo.stateKey {
                    if !states.contains(stateKey) {
                        states.append(stateKey)
                    }
                    countryStates[countryKey] = states
                }
            } else {
                if let stateKey = photo.stateKey {
                    countryStates[countryKey] = [stateKey]
                } else {
                    countryStates[countryKey] = []
                }
            }

            if let geohash = photo.geohash {
                if let count = heatmapSquares[geohash] {
                    heatmapSquares[geohash] = count + 1
                } else {
                    heatmapSquares[geohash] = 1
                }
            }

            if let cityKeys = photo.cityKeys {
                for cityKey in cityKeys {
                    if !cities.contains(cityKey) {
                        cities.append(cityKey)
                    }
                }
            }
        }
    }

    func update(context: NSManagedObjectContext) {
        for countryKey in countryStates.keys {
            let request = NSFetchRequest<VisitedCountry>(entityName: "VisitedCountry")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "countryKey == %@", countryKey)

            do {
                let models = try context.fetch(request)
                if let model = models.first,
                    let oldStates = model.stateKeys,
                    let newStates = countryStates[countryKey] {
                    model.stateKeys = Helpers.combineIntoUniqueList(oldStates, newStates)
                } else {
                    let model = VisitedCountry(context: context)
                    model.countryKey = countryKey
                    model.stateKeys = countryStates[countryKey]
                }
            } catch {
                print("Failed to fetch months.")
            }
        }

        for geohash in heatmapSquares.keys {
            guard let newCount = heatmapSquares[geohash] else { continue }

            let request = NSFetchRequest<HeatmapSquare>(entityName: "HeatmapSquare")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "geohash == %@", geohash)

            do {
                let models = try context.fetch(request)
                if let model = models.first {
                    model.count += newCount
                } else {
                    let model = HeatmapSquare(context: context)
                    model.count = newCount
                    model.geohash = geohash
                }
            } catch {
                print("Failed to fetch heatmap.")
            }
        }

        for cityKey in cities {
            let request = NSFetchRequest<VisitedCity>(entityName: "VisitedCity")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "cityKey == %d", cityKey)

            do {
                let models = try context.fetch(request)
                if models.count == 0 {
                    let model = VisitedCity(context: context)
                    model.cityKey = cityKey
                }
            } catch {
                print("Failed to fetch cities.")
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save seasons.")
        }
    }
}
