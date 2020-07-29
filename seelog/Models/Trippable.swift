//
//  Trippable.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import SwiftUI

enum StayDurationStatus {
    case tourist
    case native
    
    var name: String {
        switch self {
        case .tourist:
            return "Tourist"
        case .native:
            return "Native"
        }
    }
    
    var color: Color? {
        switch self {
        case .native:
            return .white
        default:
            return nil
        }
    }
    
}

enum ExplorationStatus {
    case visitor
    case explorer
    case conqueror

    var name: String {
        switch self {
        case .conqueror:
            return "Conqueror"
        case .explorer:
            return "Explorer"
        case .visitor:
            return "Visitor"
        }
    }

    var color: Color {
        switch self {
        case .conqueror:
            return .red
            
        case .explorer:
            return Color(UIColor.systemOrange)
            
        case .visitor:
            return .gray
        }
    }
}

enum Status {
    case notVisited // no color
    case passedThrough // no color
    case new // blue
    case regular // purple
    case explored // green
    case stayed // yellow
    case native // red
}

protocol Trippable {
    var name: String { get }
    var trips: [Trip] { get }
    var tripsByYear: [Int: [Trip]] { get }
    var stayDuration: Int { get }
    var stayDurationByYear: [Int: Int] { get }
    var years: [Int] { get }
    
    func explored(year: Int?) -> Bool?
}

extension Trippable {
    func tripsForYear(_ year: Int?) -> [Trip] {
        if let year = year {
            return trips.filter { trip in trip.years.contains(year) }
        } else {
            return trips
        }
    }

    func stayDurationForYear(_ year: Int?) -> Int {
        if let year = year {
            return self.stayDurationByYear[year] ?? 0
        } else {
            return self.stayDuration
        }
    }

    func stayStatsByYear() -> [(year: Int, count: Int)] {
        if let min = years.min() {
            return Array(min...Date().year()).map { year in (year: year, count: self.stayDurationForYear(year)) }.reversed()
        }
        return []
    }

    func stayDurationStatusForYear(_ year: Int?) -> StayDurationStatus {
        let stayDuration = stayDurationForYear(year)
        if stayDuration > 100 {
            return .native
        } else {
            return .tourist
        }
    }

    func visited(year: Int?) -> Bool {
        if let year = year {
            return years.contains(year)
        } else {
            return true
        }
    }

    func stayDurationInfo(year: Int?) -> String {
        if !visited(year: year) { return "" }
        
        var sentences: [String] = []
        let stayDuration = stayDurationForYear(year)

        if let year = year {
            let months = Set(tripsForYear(year).flatMap { trip in
                trip.months(year: year)
            }).sorted()

            if months.count < 3 {
                let monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

                sentences.append(
                    "\(stayDuration) days in \(months.map { month in monthNames[month] }.joined(separator: " and "))."
                )
            } else {
                sentences.append(
                    "\(stayDuration) days over \(months.count) months."
                )
            }
        } else {
            if years.count < 3 {
                let yearsJoined = years.map { String($0) }.joined(separator: " and ")
                sentences.append(
                    "\(stayDuration) days in \(yearsJoined)."
                )
            } else {
                sentences.append(
                    "\(stayDuration) days over \(years.count) years, first in \(String(years.first!))."
                )
            }
        }

        // how much of the year was spent there
        // how many years did you return
        return sentences.joined(separator: " ")
    }

    func status(year: Int?) -> Status {
        let stayDuration = stayDurationForYear(year)
        if stayDuration > 100 {
            if let explored = explored(year: year) {
                if explored {
                    return .native
                } else {
                    return .stayed
                }
            } else {
                return .native
            }
        } else {
            if let explored = explored(year: year) {
                if explored {
                    return .explored
                }
            }

            if let year = year, let firstYear = years.min() {
                if year == firstYear {
                    return .new
                }
            } else if years.count >= 3 {
                return .regular
            }
            return .passedThrough
        }
    }
}
