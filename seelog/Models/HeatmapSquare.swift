//
//  HeatmapSquare.swift
//  seelog
//
//  Created by Matus Tomlein on 09/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData
import GEOSwift

extension HeatmapSquare {
    static func all(context: NSManagedObjectContext) -> [HeatmapSquare]? {
        do {
            let request = NSFetchRequest<HeatmapSquare>(entityName: "HeatmapSquare")
            return try context.fetch(request)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return nil
    }

    static func allGeohashes(context: NSManagedObjectContext) -> Set<String> {
        var geohashes: Set<String> = []

        if let squares = all(context: context) {
            for square in squares {
                if let geohash = square.geohash {
                    geohashes.insert(geohash)
                }
            }
        }

        return geohashes
    }

    func lastSeenAt(aggregate: Year) -> Bool {
        return aggregate.year == lastYear
    }
}
