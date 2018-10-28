//
//  MonthStatsUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class MonthStatsUpdater {
    var updater: AggregatedStatsUpdater<String, Month>?
    var context: NSManagedObjectContext
    private var sinceAggregate: Month?

    init(context: NSManagedObjectContext) {
        self.context = context
        sinceAggregate = Month.last(context: context)
    }

    func processNewPhoto(photo: Photo) {
        guard let month = photo.month else { return }

        if updater == nil {
            updater = AggregatedStatsUpdater<String, Month>(sinceKey: sinceAggregate?.month ?? month,
                                                    sinceAggregate: sinceAggregate,
                                                    knownGeohashes: HeatmapSquare.allGeohashes(context: context),
                                                    getAllSegmentsSince: Helpers.monthsSince)
        }

        updater?.processNewPhoto(photo: photo, key: month)
    }

    func update() {
        guard let updater = self.updater else { return }

        let countriesForMonths = updater.countriesAggregated

        for month in countriesForMonths.keys {
            var model = createModel(month: month)
            updater.updateModel(key: month, model: &model)
        }
    }

    private func createModel(month: String) -> Month {
        if let model = self.sinceAggregate {
            if month == model.month {
                return model
            }
        }

        let model = Month(context: context)
        model.month = month
        return model
    }
}
