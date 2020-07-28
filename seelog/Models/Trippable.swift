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

protocol Trippable {
    var trips: [Trip] { get }
    var tripsByYear: [Int: [Trip]] { get }
    var stayDuration: Int { get }
    var stayDurationByYear: [Int: Int] { get }
    var years: [Int] { get }
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
}
