//
//  YearCitiesUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class YearCitiesUpdater {
    var citiesAggregated = [Int32: [Int64]]()
    var cumulativeCitiesAggregated = [Int32: [Int64]]()
    var sinceYear: Int32
    var sinceYearModel: Year?
    var initializationState: CurrentInitializationState

    init(sinceKey: Int32,
         sinceAggregate: Year?,
         initializationState: inout CurrentInitializationState) {
        self.sinceYear = sinceKey
        self.sinceYearModel = sinceAggregate
        self.initializationState = initializationState

        self.initializeSegments()
    }

    func processNewPhoto(photo: PhotoInfo, key: Int32) {
        if var cities = citiesAggregated[key] {
            let cityKeys = photo.cities

            for cityKey in cityKeys {
                if !cities.contains(cityKey) {
                    cities.append(cityKey)
                }

                for nextSegment in Helpers.yearsSince(key) {
                    if var cumulativeCities = cumulativeCitiesAggregated[nextSegment] {
                        if cumulativeCities.contains(cityKey) {
                            break
                        } else {
                            cumulativeCities.append(cityKey)
                            cumulativeCitiesAggregated[nextSegment] = cumulativeCities
                            initializationState.numberOfCities = cumulativeCities.count
                        }
                    }
                }
            }

            citiesAggregated[key] = cities
        }
    }

    func updateModel(key: Int32, model: inout Year) {
        model.cities = citiesAggregated[key] ?? [Int64]()
        model.cumulativeCities = cumulativeCitiesAggregated[key] ?? [Int64]()
    }

    private func initializeSegments() {
        for key in Helpers.yearsSince(sinceYear) {
            citiesAggregated[key] = []
            cumulativeCitiesAggregated[key] = []
        }

        if let firstAggregate = sinceYearModel,
            let cities = firstAggregate.cities,
            let cumulativeCities = firstAggregate.cumulativeCities {

            for city in cities {
                citiesAggregated[sinceYear]?.append(city)
            }

            for key in Helpers.yearsSince(sinceYear) {
                for city in cumulativeCities { cumulativeCitiesAggregated[key]?.append(city) }
            }
        }
    }
    
}
