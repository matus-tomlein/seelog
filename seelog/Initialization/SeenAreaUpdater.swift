//
//  YearSeenAreaUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift
import CoreData

class SeenAreaUpdater {
    var totalSeenArea: SeenArea
    var seenAreas = [Int32: SeenArea]()
    var geohashes = [Int32: Set<String>]()
    var cumulativeGeohashes: Set<String>
    var changedHeatmap = [Int32: Bool]()
    var changedCumulativeHeatmap = false
    var initializationState: CurrentInitializationState
    var context: NSManagedObjectContext
    
    init(initializationState: inout CurrentInitializationState, context: NSManagedObjectContext) {
        self.initializationState = initializationState
        self.context = context
        self.totalSeenArea = SeenArea.total(context: context)
        self.cumulativeGeohashes = Set(self.totalSeenArea.geohashes ?? [])
        if let last = SeenArea.last(context: context) {
            self.seenAreas[last.year] = last
            self.geohashes[last.year] = Set(last.geohashes ?? [])
            self.changedHeatmap[last.year] = false
        }
    }

    func processNewPhoto(photoInfo: PhotoInfo) {
        let geohash = photoInfo.geohash4

        if !cumulativeGeohashes.contains(geohash) {
            cumulativeGeohashes.insert(geohash)
            changedCumulativeHeatmap = true
        }

        if var known = geohashes[photoInfo.year] {
            if !known.contains(geohash) {
                changedHeatmap[photoInfo.year] = true
                known.insert(geohash)
                geohashes[photoInfo.year] = known
            }
        }
    }

    func update() {
        let heatmapUpdater = HeatmapUpdater(context: context)
        
        if changedCumulativeHeatmap {
            totalSeenArea.geohashes = Array(self.cumulativeGeohashes)
            heatmapUpdater.update(seenArea: totalSeenArea)
        }
        for (year, geohashes) in geohashes {
            if changedHeatmap[year] ?? false {
                if let seenArea = seenAreas[year] {
                    seenArea.geohashes = Array(geohashes)
                    heatmapUpdater.update(seenArea: seenArea)
                } else {
                    let seenArea = SeenArea(context: context)
                    seenArea.year = year
                    seenArea.geohashes = Array(geohashes)
                    heatmapUpdater.update(seenArea: seenArea)
                }
            }
        }
    }
}
