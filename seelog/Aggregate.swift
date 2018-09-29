//
//  Year.swift
//  seelog
//
//  Created by Matus Tomlein on 29/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

protocol Aggregate {
    var countries: [String]? { get }
    var name: String { get }
}

extension Year: Aggregate {
    var name: String {
        get { return String(year) }
    }
}

extension Month: Aggregate {
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
