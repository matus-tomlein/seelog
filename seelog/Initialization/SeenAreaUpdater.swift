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

class SeenAreaUpdater {
    var totalSeenArea: SeenArea
    var seenAreas = [Int32: SeenArea]()
    var geohashes = [Int32: Set<String>]()
    var travelledDistances = [Int32: Double]()
    var cumulativeGeohashes: Set<String>
    var changedGeohashes = [Int32: Bool]()
    var changedCumulativeGeohashes = false
    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        self.totalSeenArea = SeenArea.total(context: context)

        self.cumulativeGeohashes = Set(self.totalSeenArea.geohashes ?? [])
        if let last = SeenArea.last(context: context) {
            let year = last.year
            self.seenAreas[year] = last
            self.geohashes[year] = Set(last.geohashes ?? [])
            self.changedGeohashes[year] = false
        }
    }

    func processNewPhoto(photoInfo: PhotoInfo) {
        let geohash = photoInfo.geohash4
        let year = photoInfo.year

        if !cumulativeGeohashes.contains(geohash) {
            cumulativeGeohashes.insert(geohash)
            changedCumulativeGeohashes = true
        }

        if self.totalSeenArea.lastLatitude != 0 && self.totalSeenArea.lastLongitude != 0 {
            let lastLocation = CLLocation(latitude: totalSeenArea.lastLatitude, longitude: totalSeenArea.lastLongitude)
            let location = CLLocation(latitude: photoInfo.latitude, longitude: photoInfo.longitude)
            let distance = lastLocation.distance(from: location) / 1000 // km

            if let previousDistance = travelledDistances[year] {
                travelledDistances[year] = previousDistance + distance
            } else {
                travelledDistances[year] = distance
            }
            totalSeenArea.travelledDistance += distance
        }
        totalSeenArea.lastLatitude = photoInfo.latitude
        totalSeenArea.lastLongitude = photoInfo.longitude

        if var known = geohashes[year] {
            if !known.contains(geohash) {
                changedGeohashes[year] = true
                known.insert(geohash)
                geohashes[year] = known
            }
        } else {
            geohashes[year] = Set([geohash])
            changedGeohashes[year] = true
        }
    }

    func update() {
        if changedCumulativeGeohashes {
            totalSeenArea.geohashes = Array(self.cumulativeGeohashes)
        }
        for (year, geohashes) in geohashes {
            let seenArea = seenAreas[year] ?? SeenArea(context: context)
            seenArea.year = year
            if let travelledDistance = self.travelledDistances[year] {
                seenArea.travelledDistance += travelledDistance
            }

            if changedGeohashes[year] ?? false {
                if let seenArea = seenAreas[year] {
                    seenArea.geohashes = Array(geohashes)
                } else {
                    seenArea.geohashes = Array(geohashes)
                }
            }
        }
    }
}
