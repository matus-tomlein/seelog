//
//  Helpers.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class Helpers {
    static func seasonForDate(_ date: Date) -> String {
//        0: 1 December     28 February
//        1: 1 March    31 May
//        2: 1 June    31 August
//        3: 1 September    30 November
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        var season = 0
        if month >= 12 {
            season = 0
            year -= 1
        } else if month <= 2 {
            season = 0
        } else if month >= 3 && month <= 5 {
            season = 1
        } else if month >= 6 && month <= 8 {
            season = 2
        } else if month >= 9 && month <= 11 {
            season = 3
        }

        return String(year) + "-" + String(season)
    }

    static func monthForDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        return String(year) + "-" + String(month)
    }

    static func combineIntoUniqueList(_ l1: [String], _ l2: [String]) -> [String] {
        var notInL1: [String] = []
        for item in l2 {
            if !l1.contains(item) { notInL1.append(item) }
        }
        return l1 + notInL1
    }

    static func flag(country: String) -> String {
        if let countryCode = CountryCodeMappings.countryCodes[country] {
            let base = 127397
            var usv = String.UnicodeScalarView()
            for i in countryCode.utf16 {
                if let scalar = UnicodeScalar(base + Int(i)) {
                    usv.append(scalar)
                }
            }
            return String(usv)
        } else {
            return country
        }
    }
}
