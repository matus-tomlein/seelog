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

class YearSeenAreaUpdater {
    var seenAreas = [Int32: Double]()
    var cumulativeSeenAreas = [Int32: Double]()
    var sinceYear: Int32
    var sinceYearModel: Year?
    var geohashes = [Int32: Set<String>]()
    var cumulativeGeohashes = [Int32: Set<String>]()
    var changedHeatmap = [Int32: Bool]()
    var changedCumulativeHeatmap = [Int32: Bool]()
    var initializationState: CurrentInitializationState

    init(sinceYear: Int32,
         sinceYearModel: Year?,
         initializationState: inout CurrentInitializationState) {
        self.sinceYear = sinceYear
        self.sinceYearModel = sinceYearModel
        self.initializationState = initializationState
        self.initializeSegments()
    }

    func processNewPhoto(photo: PhotoInfo, key: Int32) {
        let geohash = photo.geohash4

        if let knownGeohashes = cumulativeGeohashes[key] {
            if !knownGeohashes.contains(geohash) {
                let area = Helpers.areaOf(geohash: geohash)
                for nextSegment in Helpers.yearsSince(key) {
                    cumulativeSeenAreas[nextSegment]! += area

                    if var known = cumulativeGeohashes[nextSegment]{
                        known.insert(geohash)
                        cumulativeGeohashes[nextSegment] = known
                    }

                    changedCumulativeHeatmap[nextSegment] = true
                }
                initializationState.seenArea = cumulativeSeenAreas[key] ?? 0.0
            }

            if var known = geohashes[key] {
                if !known.contains(geohash) {
                    changedHeatmap[key] = true
                    seenAreas[key]! = seenAreas[key]! + Helpers.areaOf(geohash: geohash)

                    known.insert(geohash)
                    geohashes[key] = known
                }
            }
        }
    }

    func updateModel(key: Int32, model: inout Year, context: NSManagedObjectContext) {
        if changedHeatmap[key] ?? false {
            if let processedHeatmap = model.processedHeatmapWKT {
                context.delete(processedHeatmap)
                model.processedHeatmapWKT = nil
            }
            if let land = model.landWKT {
                context.delete(land)
                model.landWKT = nil
            }
            if let water = model.waterWKT {
                context.delete(water)
                model.waterWKT = nil
            }
        }
        if changedCumulativeHeatmap[key] ?? false {
            if let cumulativeProcessedHeatmap = model.cumulativeProcessedHeatmapWKT {
                context.delete(cumulativeProcessedHeatmap)
                model.cumulativeProcessedHeatmapWKT = nil
            }
            if let land = model.cumulativeLandWKT {
                context.delete(land)
                model.cumulativeLandWKT = nil
            }
            if let water = model.cumulativeWaterWKT {
                context.delete(water)
                model.cumulativeWaterWKT = nil
            }
        }

        model.seenArea = seenAreas[key] ?? 0
        model.cumulativeSeenArea = cumulativeSeenAreas[key] ?? 0
        model.cumulativeGeohashes = Array(cumulativeGeohashes[key] ?? Set())
        model.geohashes = Array(geohashes[key] ?? Set())
    }

    private func processHeatmap(heatmap: Geometry?) -> Geometry? {
        if let heatmap = heatmap?.buffer(width: 0.05) {
            return Helpers.convexHeatmap(heatmap: heatmap)
        }
        return nil
    }

    private func initializeSegments() {
        for key in Helpers.yearsSince(sinceYear) {
            seenAreas[key] = 0
            cumulativeSeenAreas[key] = sinceYearModel?.cumulativeSeenArea ?? 0
            cumulativeGeohashes[key] = Set(sinceYearModel?.cumulativeGeohashes ?? [])
            geohashes[key] = Set()
            changedHeatmap[key] = false
            changedCumulativeHeatmap[key] = false
        }

        if let firstAggregate = sinceYearModel {
            geohashes[sinceYear] = Set(firstAggregate.geohashes ?? [])
            seenAreas[sinceYear] = firstAggregate.seenArea
        }
    }
}
