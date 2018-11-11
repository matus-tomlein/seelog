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

        if let wkt = sinceYearModel?.cumulativeHeatmapWKT?.wkt,
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

    func updateModel(key: Int32, model: inout Year, context: NSManagedObjectContext) {
        if let heatmapWKT = model.heatmapWKT {
            heatmapWKT.wkt = heatmaps[key]?.WKT
        } else {
            let heatmapWKT = GeometryWKT(context: context)
            heatmapWKT.wkt = heatmaps[key]?.WKT
            model.heatmapWKT = heatmapWKT
        }

        if let cumulativeHeatmapWKT = model.cumulativeHeatmapWKT {
            cumulativeHeatmapWKT.wkt = cumulativeHeatmapWKTs[key]
        } else {
            let cumulativeHeatmapWKT = GeometryWKT(context: context)
            cumulativeHeatmapWKT.wkt = cumulativeHeatmapWKTs[key]
            model.cumulativeHeatmapWKT = cumulativeHeatmapWKT
        }

        if let processedHeatmap = processHeatmap(heatmap: heatmaps[key]),
            let land = HeatmapMapManager.landsPolygon?.difference(processedHeatmap),
            let water = HeatmapMapManager.waterPolygon?.difference(processedHeatmap) {
            if let processedWKT = model.processedHeatmapWKT {
                processedWKT.wkt = processedHeatmap.WKT
            } else {
                let processedWKT = GeometryWKT(context: context)
                processedWKT.wkt = processedHeatmap.WKT
                model.processedHeatmapWKT = processedWKT
            }

            if let landWKT = model.landWKT {
                landWKT.wkt = land.WKT
            } else {
                let landWKT = GeometryWKT(context: context)
                landWKT.wkt = land.WKT
                model.landWKT = landWKT
            }

            if let waterWKT = model.waterWKT {
                waterWKT.wkt = water.WKT
            } else {
                let waterWKT = GeometryWKT(context: context)
                waterWKT.wkt = water.WKT
                model.waterWKT = waterWKT
            }
        }

        if let wkt = cumulativeHeatmapWKTs[key],
            let cumulativeHeatmap = Helpers.geometry(fromWKT: wkt),
            let processedHeatmap = processHeatmap(heatmap: cumulativeHeatmap),
            let land = HeatmapMapManager.landsPolygon?.difference(processedHeatmap),
            let water = HeatmapMapManager.waterPolygon?.difference(processedHeatmap) {
            if let processedWKT = model.cumulativeProcessedHeatmapWKT {
                processedWKT.wkt = processedHeatmap.WKT
            } else {
                let processedWKT = GeometryWKT(context: context)
                processedWKT.wkt = processedHeatmap.WKT
                model.cumulativeProcessedHeatmapWKT = processedWKT
            }

            if let landWKT = model.cumulativeLandWKT {
                landWKT.wkt = land.WKT
            } else {
                let landWKT = GeometryWKT(context: context)
                landWKT.wkt = land.WKT
                model.cumulativeLandWKT = landWKT
            }

            if let waterWKT = model.cumulativeWaterWKT {
                waterWKT.wkt = water.WKT
            } else {
                let waterWKT = GeometryWKT(context: context)
                waterWKT.wkt = water.WKT
                model.cumulativeWaterWKT = waterWKT
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
            if let wkt = cumulativeHeatmap?.WKT { cumulativeHeatmapWKTs[key] = wkt }
        }

        if let firstAggregate = sinceYearModel {
            geohashes[sinceYear] = Set(firstAggregate.geohashes ?? [])
            seenAreas[sinceYear] = firstAggregate.seenArea
            if let wkt = firstAggregate.heatmapWKT?.wkt, let geometry = Helpers.geometry(fromWKT: wkt) { heatmaps[sinceYear] = geometry }
        }
    }
}
