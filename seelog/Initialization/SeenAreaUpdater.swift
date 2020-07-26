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
import CoreLocation

struct YearMonth: Hashable {
    let year: Int32
    let month: Int16
}

class SeenAreaUpdater {
    var totalSeenArea: SeenArea
    var seenAreas = [YearMonth: SeenArea]()
    var geohashes = [YearMonth: Set<String>]()
    var travelledDistances = [YearMonth: Double]()
    var cumulativeGeohashes: Set<String>
    var changedHeatmap = [YearMonth: Bool]()
    var changedCumulativeHeatmap = false
    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        self.totalSeenArea = SeenArea.total(context: context)

        self.cumulativeGeohashes = Set(self.totalSeenArea.geohashes ?? [])
        if let last = SeenArea.last(context: context) {
            let yearMonth = YearMonth(year: last.year, month: last.month)
            self.seenAreas[yearMonth] = last
            self.geohashes[yearMonth] = Set(last.geohashes ?? [])
            self.changedHeatmap[yearMonth] = false
        }
    }

    func processNewPhoto(photoInfo: PhotoInfo) {
        let geohash = photoInfo.geohash4
        let yearMonth = YearMonth(year: photoInfo.year, month: photoInfo.month)

        if !cumulativeGeohashes.contains(geohash) {
            cumulativeGeohashes.insert(geohash)
            changedCumulativeHeatmap = true
        }

        if self.totalSeenArea.lastLatitude != 0 && self.totalSeenArea.lastLongitude != 0 {
            let lastLocation = CLLocation(latitude: totalSeenArea.lastLatitude, longitude: totalSeenArea.lastLongitude)
            let location = CLLocation(latitude: photoInfo.latitude, longitude: photoInfo.longitude)
            let distance = lastLocation.distance(from: location) / 1000 // km

            if let previousDistance = travelledDistances[yearMonth] {
                travelledDistances[yearMonth] = previousDistance + distance
            } else {
                travelledDistances[yearMonth] = distance
            }
            totalSeenArea.travelledDistance += distance
        }
        totalSeenArea.lastLatitude = photoInfo.latitude
        totalSeenArea.lastLongitude = photoInfo.longitude

        if var known = geohashes[yearMonth] {
            if !known.contains(geohash) {
                changedHeatmap[yearMonth] = true
                known.insert(geohash)
                geohashes[yearMonth] = known
            }
        } else {
            geohashes[yearMonth] = Set([geohash])
            changedHeatmap[yearMonth] = true
        }
    }

    func update() {
        let heatmapUpdater = HeatmapUpdater(context: context)

        if changedCumulativeHeatmap {
            totalSeenArea.geohashes = Array(self.cumulativeGeohashes)
            heatmapUpdater.update(seenArea: totalSeenArea)
        }
        for (yearMonth, geohashes) in geohashes {
            let seenArea = seenAreas[yearMonth] ?? SeenArea(context: context)
            seenArea.year = yearMonth.year
            seenArea.month = yearMonth.month
            if let travelledDistance = self.travelledDistances[yearMonth] {
                seenArea.travelledDistance += travelledDistance
            }

            if changedHeatmap[yearMonth] ?? false {
                if let seenArea = seenAreas[yearMonth] {
                    seenArea.geohashes = Array(geohashes)
                    heatmapUpdater.update(seenArea: seenArea)
                } else {
                    seenArea.geohashes = Array(geohashes)
                    heatmapUpdater.update(seenArea: seenArea)
                }
            }
        }
    }
}
