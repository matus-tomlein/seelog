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
    var updater: AggregatedStatsUpdater<String, Season>?
    var context: NSManagedObjectContext
    private var sinceAggregate: Season?

    init(context: NSManagedObjectContext) {
        self.context = context
        sinceAggregate = Season.last(context: context)
    }

    func processNewPhoto(photo: Photo) {
        guard let season = photo.season else { return }

        if updater == nil {
            updater = AggregatedStatsUpdater<String, Season>(sinceKey: sinceAggregate?.season ?? season,
                                                     sinceAggregate: sinceAggregate,
                                                     knownHeatmapSquares: HeatmapSquare.all(context: context),
                                                     getAllSegmentsSince: Helpers.seasonsSince)
        }

        updater?.processNewPhoto(photo: photo, key: season)
    }

    func update() {
        guard let updater = self.updater else { return }

        for season in updater.countriesAggregated.keys {
            var model = createModel(season: season)
            updater.updateModel(key: season, model: &model)
        }
    }

    private func createModel(season: String) -> Season {
        if let model = self.sinceAggregate {
            if season == model.season {
                return model
            }
        }

        let model = Season(context: context)
        model.season = season
        return model
    }

}
