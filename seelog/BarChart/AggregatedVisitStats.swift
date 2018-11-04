//
//  Country.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

enum Granularity {
    case years
    case seasons
    case months
}

class AggregatedVisitStats {
    var years: [Year]?

    var names: [String]? {
        get {
            if let aggregates = self.years {
                return aggregates.map { $0.name }
            }
            return nil
        }
    }

    func aggregateWithName(_ name: String) -> Year? {
        if let aggregates = self.years {
            let filtered = aggregates.filter { $0.name == name }
            if filtered.count > 0 { return filtered[0] }
        }
        return nil
    }

    func loadItems(context: NSManagedObjectContext) {
        do {
            self.years = try {
                let request = NSFetchRequest<Year>(entityName: "Year")
                request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
                return try context.fetch(request)
            }()
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
}
