//
//  YearContinentsUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 18/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class YearContinentsUpdater {
    var sinceYear: Int32
    var sinceYearModel: Year?
    var continentsAggregated = [Int32: [String]]()
    var cumulativeContinentsAggregated = [Int32: [String]]()
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
        if let continent = photo.continent {
            if var continents = continentsAggregated[key] {
                if !continents.contains(continent) {
                    continents.append(continent)
                }
                continentsAggregated[key] = continents

                for nextSegment in Helpers.yearsSince(key) {
                    if var cumulativeContinents = cumulativeContinentsAggregated[nextSegment] {
                        if cumulativeContinents.contains(continent) {
                            break
                        } else {
                            cumulativeContinents.append(continent)
                            cumulativeContinentsAggregated[nextSegment] = cumulativeContinents
                            initializationState.numberOfContinents = cumulativeContinents.count
                        }
                    }
                }

            }
        }
    }

    func updateModel(key: Int32, model: inout Year) {
        model.continents = continentsAggregated[key]
        model.cumulativeContinents = cumulativeContinentsAggregated[key]
    }

    private func initializeSegments() {
        for key in Helpers.yearsSince(sinceYear) {
            continentsAggregated[key] = []
            cumulativeContinentsAggregated[key] = []
        }

        if let firstAggregate = sinceYearModel,
            let continents = firstAggregate.continents,
            let cumulativeContinents = firstAggregate.cumulativeContinents {

            for continent in continents { continentsAggregated[sinceYear]?.append(continent) }

            for key in Helpers.yearsSince(sinceYear) {
                for continent in cumulativeContinents { cumulativeContinentsAggregated[key]?.append(continent) }
            }
        }
    }

}
