//
//  YearHeatmapUpdater.swift
//  seelog
//
//  Created by Matus Tomlein on 17/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift
import CoreData

class YearHeatmapUpdater {
    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func update(year: Year, cumulative: Bool) {
        if let geohashes = year.geohashes(cumulative: cumulative),
            let heatmap = heatmapFor(geohashes: geohashes),
            let (wkt, landWKT, waterWKT) = processHeatmap(heatmap: heatmap) {

            let wktModel = GeometryWKT(context: context)
            wktModel.wkt = wkt

            let landWKTModel = GeometryWKT(context: context)
            landWKTModel.wkt = landWKT

            let waterWKTModel = GeometryWKT(context: context)
            waterWKTModel.wkt = waterWKT

            if cumulative {
                year.cumulativeProcessedHeatmapWKT = wktModel
                year.cumulativeLandWKT = landWKTModel
                year.cumulativeWaterWKT = waterWKTModel
            } else {
                year.processedHeatmapWKT = wktModel
                year.landWKT = landWKTModel
                year.waterWKT = waterWKTModel
            }
        }
    }

    private func heatmapFor(geohashes: [String]) -> Geometry? {
        let polygons = geohashes.map({ Helpers.polygonFor(geohash: $0) as? Polygon }).filter({ $0 != nil }).map({ $0! })
        return MultiPolygon(geometries: polygons)
    }

    private func processHeatmap(heatmap: Geometry) -> (String, String, String)? {
        if let buffered = heatmap.buffer(width: 0.05) {
            let processedHeatmap = Helpers.convexHeatmap(heatmap: buffered)

            if let land = HeatmapMapManager.landsPolygon?.difference(processedHeatmap),
                let water = HeatmapMapManager.waterPolygon?.difference(processedHeatmap) {
                if let processedWKT = processedHeatmap.WKT,
                    let landWKT = land.WKT,
                    let waterWKT = water.WKT {
                    return (processedWKT, landWKT, waterWKT)
                }
            }
        }

        return nil
    }
}
