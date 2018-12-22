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

    private var citiesUpdater: YearCitiesUpdater?
    private var countriesUpdater: YearCountriesUpdater?
    private var seenAreaAndHeatmapUpdater: YearSeenAreaUpdater?
    private var timezonesUpdater: YearTimezonesUpdater?
    private var continentsUpdater: YearContinentsUpdater?
    private var initializationState: CurrentInitializationState

    init(initializationState: inout CurrentInitializationState, context: NSManagedObjectContext) {
        self.context = context
        sinceAggregate = Year.last(context: context)
        self.initializationState = initializationState
    }

    func processNewPhoto(photoInfo: PhotoInfo) {

        if countriesUpdater == nil {
            let sinceKey = sinceAggregate?.year ?? photoInfo.year

            countriesUpdater = YearCountriesUpdater(sinceKey: sinceKey,
                                                    sinceAggregate: sinceAggregate,
                                                    initializationState: &initializationState)

            citiesUpdater = YearCitiesUpdater(sinceKey: sinceKey,
                                              sinceAggregate: sinceAggregate,
                                              initializationState: &initializationState)

            seenAreaAndHeatmapUpdater = YearSeenAreaUpdater(sinceYear: sinceKey,
                                                            sinceYearModel: sinceAggregate,
                                                            initializationState: &initializationState)

            timezonesUpdater = YearTimezonesUpdater(sinceKey: sinceKey,
                                                    sinceAggregate: sinceAggregate,
                                                    initializationState: &initializationState)

            continentsUpdater = YearContinentsUpdater(sinceKey: sinceKey,
                                                      sinceAggregate: sinceAggregate,
                                                      initializationState: &initializationState)
        }

        countriesUpdater?.processNewPhoto(photo: photoInfo, key: photoInfo.year)
        citiesUpdater?.processNewPhoto(photo: photoInfo, key: photoInfo.year)
        seenAreaAndHeatmapUpdater?.processNewPhoto(photo: photoInfo, key: photoInfo.year)
        timezonesUpdater?.processNewPhoto(photo: photoInfo, key: photoInfo.year)
        continentsUpdater?.processNewPhoto(photo: photoInfo, key: photoInfo.year)
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
