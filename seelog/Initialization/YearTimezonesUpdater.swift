//
//  YearTimezonesUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class YearTimezonesUpdater {
    var sinceYear: Int32
    var sinceYearModel: Year?
    var timezonesAggregated = [Int32: [Int32]]()
    var cumulativeTimezonesAggregated = [Int32: [Int32]]()
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
        if let timezone = photo.timezone {
            if var timezones = timezonesAggregated[key] {
                if !timezones.contains(timezone) {
                    timezones.append(timezone)
                }
                timezonesAggregated[key] = timezones

                for nextSegment in Helpers.yearsSince(key) {
                    if var cumulativeTimezones = cumulativeTimezonesAggregated[nextSegment] {
                        if cumulativeTimezones.contains(timezone) {
                            break
                        } else {
                            cumulativeTimezones.append(timezone)
                            cumulativeTimezonesAggregated[nextSegment] = cumulativeTimezones
                            initializationState.numberOfTimezones = cumulativeTimezones.count
                        }
                    }
                }

            }
        }
    }

    func updateModel(key: Int32, model: inout Year) {
        model.timezones = timezonesAggregated[key]
        model.cumulativeTimezones = cumulativeTimezonesAggregated[key]
    }

    private func initializeSegments() {
        for key in Helpers.yearsSince(sinceYear) {
            timezonesAggregated[key] = []
            cumulativeTimezonesAggregated[key] = []
        }

        if let firstAggregate = sinceYearModel,
            let timezones = firstAggregate.timezones,
            let cumulativeTimezones = firstAggregate.cumulativeTimezones {

            for tz in timezones { timezonesAggregated[sinceYear]?.append(tz) }

            for key in Helpers.yearsSince(sinceYear) {
                for tz in cumulativeTimezones { cumulativeTimezonesAggregated[key]?.append(tz) }
            }
        }
    }
}
