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
    var updater: AggregatedStatsUpdater<Int32, Year>?
    var context: NSManagedObjectContext
    private var sinceAggregate: Year?

    init(context: NSManagedObjectContext) {
        self.context = context
        sinceAggregate = Year.last(context: context)
    }

    func processNewPhoto(photo: Photo) {
        guard let year = photo.year else { return }

        if updater == nil {
            updater = AggregatedStatsUpdater<Int32, Year>(sinceKey: sinceAggregate?.year ?? year,
                                                    sinceAggregate: sinceAggregate,
                                                    knownGeohashes: HeatmapSquare.allGeohashes(context: context),
                                                    getAllSegmentsSince: Helpers.yearsSince)
        }

        updater?.processNewPhoto(photo: photo, key: year)
    }

    func update() {
        guard let updater = self.updater else { return }

        for year in updater.countriesAggregated.keys {
            var model = createModel(year: year)
            updater.updateModel(key: year, model: &model)
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
