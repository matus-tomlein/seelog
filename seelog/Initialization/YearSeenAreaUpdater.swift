//
//  YearSeenAreaUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

class YearSeenAreaUpdater {
    var heatmaps = [Int32: Geometry]()
    var cumulativeHeatmapWKTs = [Int32: String]()
    var cumulativeHeatmap: Geometry?
    var seenAreas = [Int32: Double]()
    var cumulativeSeenAreas = [Int32: Double]()
    var sinceYear: Int32
    var sinceYearModel: Year?
    var knownGeohashes: Set<String>
    var knownGeohashesForKey = [Int32: Set<String>]()

    init(sinceYear: Int32,
         sinceYearModel: Year?,
         knownHeatmapSquares: [HeatmapSquare]?) {
        self.sinceYear = sinceYear
        self.sinceYearModel = sinceYearModel

        knownGeohashes = Set(knownHeatmapSquares?.map({ $0.geohash! }) ?? [])
        if let sinceAggregate = sinceYearModel {
            let knownForSince = Set(knownHeatmapSquares?.filter({ $0.lastSeenAt(aggregate: sinceAggregate) }).map({ $0.geohash! }) ?? [])
            knownGeohashesForKey[sinceYear] = knownForSince
        }

        if let wkt = sinceYearModel?.cumulativeHeatmapWKT,
            let heatmap = Helpers.geometry(fromWKT: wkt) {
            self.cumulativeHeatmap = heatmap
        }

        self.initializeSegments()
    }

    func processNewPhoto(photo: Photo, key: Int32) {
        if let geohash = photo.geohash {
            if !knownGeohashes.contains(geohash) {
                if let squarePolygon = Helpers.polygonFor(geohash: geohash) {
                    let newHeatmap = cumulativeHeatmap?.union(squarePolygon) ?? squarePolygon
                    self.cumulativeHeatmap = newHeatmap

                    if let wkt = newHeatmap.WKT {
                        for nextSegment in Helpers.yearsSince(key) {
                            cumulativeHeatmapWKTs[nextSegment] = wkt
                        }
                    }
                }

                let area = Helpers.areaOf(geohash: geohash)
                for nextSegment in Helpers.yearsSince(key) {
                    cumulativeSeenAreas[nextSegment]! += area
                }

                knownGeohashes.insert(geohash)
            }

            if var known = knownGeohashesForKey[key] {
                if !known.contains(geohash) {
                    seenAreas[key]! = seenAreas[key]! + Helpers.areaOf(geohash: geohash)

                    if let squarePolygon = Helpers.polygonFor(geohash: geohash) {
                        heatmaps[key] = heatmaps[key]?.union(squarePolygon) ?? squarePolygon
                    }

                    known.insert(geohash)
                    knownGeohashesForKey[key] = known
                }
            }
        }
    }

    func updateModel(key: Int32, model: inout Year) {
        model.heatmapWKT = heatmaps[key]?.WKT
        model.heatmapWKTProcessed = processHeatmap(heatmap: heatmaps[key])?.WKT
        if let wkt = cumulativeHeatmapWKTs[key] {
            model.cumulativeHeatmapWKT = wkt
            model.cumulativeHeatmapWKTProcessed = processHeatmap(heatmap: Helpers.geometry(fromWKT: wkt))?.WKT
        }
        model.seenArea = seenAreas[key]!
        model.cumulativeSeenArea = cumulativeSeenAreas[key]!
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
            cumulativeSeenAreas[key] = 0
            if knownGeohashesForKey[key] == nil {
                knownGeohashesForKey[key] = Set()
            }
            if let wkt = cumulativeHeatmap?.WKT { cumulativeHeatmapWKTs[key] = wkt }
        }

        if let firstAggregate = sinceYearModel {
            seenAreas[sinceYear] = firstAggregate.seenArea
            if let wkt = firstAggregate.heatmapWKT, let geometry = Helpers.geometry(fromWKT: wkt) { heatmaps[sinceYear] = geometry }

            for key in Helpers.yearsSince(sinceYear) {
                cumulativeSeenAreas[key] = firstAggregate.cumulativeSeenArea
            }
        }
    }
}
