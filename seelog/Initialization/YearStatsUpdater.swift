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
    var context: NSManagedObjectContext
    private var sinceAggregate: Year?
    private var geoDB: GeoDatabase

    private var citiesUpdater: YearCitiesUpdater?
    private var countriesUpdater: YearCountriesUpdater?
    private var seenAreaAndHeatmapUpdater: YearSeenAreaUpdater?
    private var timezonesUpdater: YearTimezonesUpdater?
    private var continentsUpdater: YearContinentsUpdater?
    private var initializationState: CurrentInitializationState

    init(initializationState: inout CurrentInitializationState, geoDB: GeoDatabase, context: NSManagedObjectContext) {
        self.context = context
        sinceAggregate = Year.last(context: context)
        self.initializationState = initializationState
        self.geoDB = geoDB
    }

    func processNewPhoto(photo: Photo) {
        if countriesUpdater == nil {
            let sinceKey = sinceAggregate?.year ?? photo.year

            countriesUpdater = YearCountriesUpdater(sinceKey: sinceKey,
                                                    sinceAggregate: sinceAggregate,
                                                    geoDB: geoDB,
                                                    initializationState: &initializationState)

            citiesUpdater = YearCitiesUpdater(sinceKey: sinceKey,
                                              sinceAggregate: sinceAggregate,
                                              geoDB: geoDB,
                                              initializationState: &initializationState)

            seenAreaAndHeatmapUpdater = YearSeenAreaUpdater(sinceYear: sinceKey,
                                                            sinceYearModel: sinceAggregate,
                                                            initializationState: &initializationState)

            timezonesUpdater = YearTimezonesUpdater(sinceKey: sinceKey,
                                                    sinceAggregate: sinceAggregate,
                                                    geoDB: geoDB,
                                                    initializationState: &initializationState)

            continentsUpdater = YearContinentsUpdater(sinceKey: sinceKey,
                                                      sinceAggregate: sinceAggregate,
                                                      geoDB: geoDB,
                                                      initializationState: &initializationState)
        }

        countriesUpdater?.processNewPhoto(photo: photo, key: photo.year)
        citiesUpdater?.processNewPhoto(photo: photo, key: photo.year)
        seenAreaAndHeatmapUpdater?.processNewPhoto(photo: photo, key: photo.year)
        timezonesUpdater?.processNewPhoto(photo: photo, key: photo.year)
        continentsUpdater?.processNewPhoto(photo: photo, key: photo.year)
    }

    func update() {
        guard let countriesUpdater = self.countriesUpdater else { return }
        guard let citiesUpdater = self.citiesUpdater else { return }
        guard let seenAreaAndHeatmapUpdater = self.seenAreaAndHeatmapUpdater else { return }
        guard let timezonesUpdater = self.timezonesUpdater else { return }

        for year in countriesUpdater.countriesAggregated.keys {
            var model = createModel(year: year)
            countriesUpdater.updateModel(key: year, model: &model)
            citiesUpdater.updateModel(key: year, model: &model)
            timezonesUpdater.updateModel(key: year, model: &model)
            seenAreaAndHeatmapUpdater.updateModel(key: year, model: &model, context: context)
            continentsUpdater?.updateModel(key: year, model: &model)
        }
    }

    private func createModel(year: Int32) -> Year {
        if let model = self.sinceAggregate {
            if year == model.year {
                return model
            }
        }

        let model = Year(context: context)
        model.year = year
        return model
    }

}
