//
//  Year.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

protocol Aggregate {
    var countries: [String: [String]]? { get set }
    var cumulativeCountries: [String: [String]]? { get set }
    var cities: [Int64]? { get set }
    var cumulativeCities: [Int64]? { get set }
    var heatmapWKT: String? { get set }
    var cumulativeHeatmapWKT: String? { get set }
    var seenArea: Double { get set }
    var cumulativeSeenArea: Double { get set }
    var cumulativeHeatmapWKTProcessed: String? { get set }
    var heatmapWKTProcessed: String? { get set }
    var name: String { get }
}

extension Aggregate {
    func chartValue(selectedTab: SelectedTab, cumulative: Bool) -> Double {
        if cumulative {
            if selectedTab == .countries {
                return Double(cumulativeCountries?.count ?? 0)
            } else {
                return cumulativeSeenArea
            }
        } else {
            if selectedTab == .countries {
                return Double(countries?.count ?? 0)
            } else {
                return seenArea
            }
        }
    }

    func chartLabel(selectedTab: SelectedTab, cumulative: Bool) -> String {
        let value = chartValue(selectedTab: selectedTab, cumulative: cumulative)
        if selectedTab == .countries {
            return String(Int(value))
        } else {
            if value > 1000 {
                return String(Int(round(value / 1000))) + "k"
            } else {
                return String(Int(round(value)))
            }
        }
    }

    func countries(cumulative: Bool) -> [String: [String]]? {
        return cumulative ? cumulativeCountries : countries
    }

    func cities(cumulative: Bool) -> [Int64]? {
        return cumulative ? cumulativeCities : cities
    }

    func heatmapWKT(cumulative: Bool) -> String? {
        return cumulative ? cumulativeHeatmapWKTProcessed : heatmapWKTProcessed
    }
}

extension Year: Aggregate {
    static func last(context: NSManagedObjectContext) -> Year? {
        let request = NSFetchRequest<Year>(entityName: "Year")
        request.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "year", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            return try context.fetch(request).first
        } catch _ {
            print("Failed to retrieve last year")
        }

        return nil
    }

    var name: String {
        get { return String(year) }
    }
}

extension Month: Aggregate {
    static func last(context: NSManagedObjectContext) -> Month? {
        let request = NSFetchRequest<Month>(entityName: "Month")
        request.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "month", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            return try context.fetch(request).first
        } catch _ {
            print("Failed to retrieve last year")
        }

        return nil
    }

    var name: String {
        get {
            if let month = month {
                let parts = month.split(separator: "-")
                if parts.count == 2 {
                    return parts[1] + "/" + parts[0].suffix(2)
                }
            }
            return month ?? ""
        }
    }
}

extension Season: Aggregate {
    static func last(context: NSManagedObjectContext) -> Season? {
        let request = NSFetchRequest<Season>(entityName: "Season")
        request.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "season", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            return try context.fetch(request).first
        } catch _ {
            print("Failed to retrieve last year")
        }

        return nil
    }

    var name: String {
        get {
            if let season = season {
                let parts = season.split(separator: "-")
                if parts.count == 2 {
                    let months = [
                        "0": "Dec-Feb",
                        "1": "Mar-May",
                        "2": "Jun-Aug",
                        "3": "Sep-Nov"
                    ][parts[1]]

                    var year = parts[0].suffix(2)
                    if parts[1] == "0" {
                        year += "-" + String(format: "%02d", (Int(year) ?? 0) + 1)
                    }

                    return (months ?? "") + "\n" + year
                }
            }
            return season ?? ""
        }
    }
}
