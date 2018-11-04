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

    init(context: NSManagedObjectContext) {
        self.context = context
        sinceAggregate = Year.last(context: context)
    }

    func processNewPhoto(photo: Photo) {
        guard let year = photo.year else { return }

        if countriesUpdater == nil {
            let sinceKey = sinceAggregate?.year ?? year
            let knownHeatmapSquares = HeatmapSquare.all(context: context)

            countriesUpdater = YearCountriesUpdater(sinceKey: sinceKey,
                                                    sinceAggregate: sinceAggregate)

            citiesUpdater = YearCitiesUpdater(sinceKey: sinceKey,
                                              sinceAggregate: sinceAggregate)

            seenAreaAndHeatmapUpdater = YearSeenAreaUpdater(sinceYear: sinceKey,
                                                            sinceYearModel: sinceAggregate,
                                                            knownHeatmapSquares: knownHeatmapSquares)

            timezonesUpdater = YearTimezonesUpdater(sinceKey: sinceKey,
                                                    sinceAggregate: sinceAggregate)
        }

        countriesUpdater?.processNewPhoto(photo: photo, key: year)
        citiesUpdater?.processNewPhoto(photo: photo, key: year)
        seenAreaAndHeatmapUpdater?.processNewPhoto(photo: photo, key: year)
        timezonesUpdater?.processNewPhoto(photo: photo, key: year)
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
            seenAreaAndHeatmapUpdater.updateModel(key: year, model: &model)
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
