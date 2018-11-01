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
    var granularity: Granularity?
    var aggregates: [Aggregate]?

    var names: [String]? {
        get {
            if let aggregates = self.aggregates {
                return aggregates.map { $0.name }
            }
            return nil
        }
    }

    func countriesForSelection(name: String, aggregate: Bool) -> [String]? {
        return countriesAndStatesForSelection(name: name, aggregate: aggregate)?.keys.sorted()
    }

    func countriesAndStatesForSelection(name: String, aggregate: Bool) -> [String: [String]]? {
        if let aggregates = self.aggregates {
            let filtered = aggregates.filter { $0.name == name }
            if filtered.count > 0 {
                return aggregate ? filtered[0].cumulativeCountries : filtered[0].countries
            }
        }
        return nil
    }

    func allCountries() -> [String]? {
        if let aggregates = self.aggregates {
            var allCountries: [String] = []
            for aggregate in aggregates {
                if let countries = aggregate.countries {
                    for country in countries.keys {
                        if !allCountries.contains(country) {
                            allCountries.append(country)
                        }
                    }
                }
            }
            return allCountries.sorted()
        }
        return nil
    }

    func loadItems(granularity: Granularity, context: NSManagedObjectContext) {
        self.granularity = granularity

        do {
            self.aggregates = try {
                switch granularity {
                case .years:
                    let request = NSFetchRequest<Year>(entityName: "Year")
                    request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
                    return try context.fetch(request)

                case .months:
                    let request = NSFetchRequest<Month>(entityName: "Month")
                    request.sortDescriptors = [NSSortDescriptor(key: "month", ascending: true)]
                    return try context.fetch(request)

                case .seasons:
                    let request = NSFetchRequest<Season>(entityName: "Season")
                    request.sortDescriptors = [NSSortDescriptor(key: "season", ascending: true)]
                    return try context.fetch(request)
                }
            }()
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
}
