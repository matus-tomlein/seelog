//
//  TextInfoGenerator.swift
//  seelog
//
//  Created by Matus Tomlein on 27/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

class TextInfoGenerator {

    static func countries(model: DomainModel, year: Int?, linkToCountries: Bool = true) -> [TextInfo] {
        var heading = ""
        var body: [String] = []
        if let year = year {
            heading = "In \(year), you visited \(model.countriesForYear(year).count) countries."
        } else {
            heading = "You visited \(model.countriesForYear(year).count) countries so far!"

            let countriesByYear = model.years.map { year in (year: year.year, count: year.countries.count) }
            if let maxPerYear = countriesByYear.map({ p in p.count }).max() {
                let years = countriesByYear.filter { p in p.count == maxPerYear }.map { p in "\(p.year)" }.joined(separator: ", ")
                body.append("In \(years), you visited \(maxPerYear) countries per year.")
            }
        }

        return [
            TextInfo(
                id: "countries",
                link: linkToCountries ? .countries : .none,
                heading: heading,
                body: body
            )
        ]
    }

    static func cities(model: DomainModel, year: Int?) -> [TextInfo] {
        return [
            TextInfo(
                id: "cities",
                link: .cities,
                heading: "You visited \(model.citiesForYear(year).count) cities so far!"
            )
        ]
    }

    static func continents(model: DomainModel, year: Int?) -> [TextInfo] {
        let info = TextInfo(
            id: "continents",
            link: .continents,
            heading: "You visited \(model.continentsForYear(year).count) continents so far!"
        )
        return [
            info
        ]
    }

    static func timezones(model: DomainModel, year: Int?) -> [TextInfo] {
        let info = TextInfo(
            id: "timezones",
            link: .timezones,
            heading: "You visited \(model.timezonesForYear(year).count) timezones so far!"
        )
        return [
            info
        ]
    }

}
