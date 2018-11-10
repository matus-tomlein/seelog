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
    var geohashes = [Int32: Set<String>]()
    var cumulativeGeohashes = [Int32: Set<String>]()

    init(sinceYear: Int32,
         sinceYearModel: Year?) {
        self.sinceYear = sinceYear
        self.sinceYearModel = sinceYearModel

        if let wkt = sinceYearModel?.cumulativeHeatmapWKT,
            let heatmap = Helpers.geometry(fromWKT: wkt) {
            self.cumulativeHeatmap = heatmap
        }

        self.initializeSegments()
    }

    func processNewPhoto(photo: Photo, key: Int32) {
        if let geohash = photo.geohash, let knownGeohashes = cumulativeGeohashes[key] {
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

                    if var known = cumulativeGeohashes[nextSegment]{
                        known.insert(geohash)
                        cumulativeGeohashes[nextSegment] = known
                    }
                }
            }

            if var known = geohashes[key] {
                if !known.contains(geohash) {
                    seenAreas[key]! = seenAreas[key]! + Helpers.areaOf(geohash: geohash)

                    if let squarePolygon = Helpers.polygonFor(geohash: geohash) {
                        heatmaps[key] = heatmaps[key]?.union(squarePolygon) ?? squarePolygon
                    }

                    known.insert(geohash)
                    geohashes[key] = known
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
            if let wkt = cumulativeHeatmap?.WKT { cumulativeHeatmapWKTs[key] = wkt }
        }

        if let firstAggregate = sinceYearModel {
            geohashes[sinceYear] = Set(firstAggregate.geohashes ?? [])
            seenAreas[sinceYear] = firstAggregate.seenArea
            if let wkt = firstAggregate.heatmapWKT, let geometry = Helpers.geometry(fromWKT: wkt) { heatmaps[sinceYear] = geometry }
        }
    }
}
