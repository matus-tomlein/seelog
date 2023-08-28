//
//  ModelCache.swift
//  seelog
//
//  Created by Matus Tomlein on 26/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import Foundation
import GEOSwift

class ModelCache {
    private var model: DomainModel
    
    init(model: DomainModel) {
        self.model = model
    }
    
    private var seenPolygonsCache: [Int?: [ZoomType: [Polygon]]] = [:]
    func seenPolygons(year: Int?, zoomType: ZoomType) -> [Polygon] {
        if let zoomTypes = seenPolygonsCache[year],
           let polygons = zoomTypes[zoomType] {
            return polygons
        }
        
        let polygons = model.seenGeometry(year: year)?.polygons(zoomType: zoomType) ?? []
        
        if var zoomTypes = seenPolygonsCache[year] {
            zoomTypes[zoomType] = polygons
        } else {
            seenPolygonsCache[year] = [zoomType: polygons]
        }
        
        return polygons
    }
}
