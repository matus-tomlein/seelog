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
            let (wkt, landWKT, waterWKT) = processHeatmap(heatmap: heatmap.geometry) {

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

    private func heatmapFor(geohashes: [String]) -> GeometryConvertible? {
        let polygons = geohashes.map({ Helpers.polygonFor(geohash: $0) as? Polygon }).filter({ $0 != nil }).map({ $0! })
        return MultiPolygon(polygons: polygons)
    }

    private func processHeatmap(heatmap: Geometry) -> (String, String, String)? {
        if let buffered = try? heatmap.buffer(by: 0.05) {
            let processedHeatmap = Helpers.convexHeatmap(heatmap: buffered)

            if let landsPolygon = WorldPolygons.landsPolygon,
                let waterPolygon = WorldPolygons.waterPolygon,
                let land = try? landsPolygon.difference(with: processedHeatmap),
                let water = try? waterPolygon.difference(with: processedHeatmap) {
                if let processedWKT = try? processedHeatmap.wkt(),
                    let landWKT = try? land.wkt(),
                    let waterWKT = try? water.wkt() {
                    return (processedWKT, landWKT, waterWKT)
                }
            }
        }

        return nil
    }
}
