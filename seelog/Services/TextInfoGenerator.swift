//
//  TextInfoGenerator.swift
//  seelog
//
//  Created by Matus Tomlein on 27/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

class TextInfoGenerator {
    
    static func travelledDistance(model: DomainModel, year: Int?) -> [TextInfo] {
        var body: [String] = []
        let distanceRounded = model.seenGeometry(year: year)?.travelledDistanceRounded ?? 0
        let distance = model.seenGeometry(year: year)?.travelledDistance ?? 0
        let earthCircumference = 40075.0
        let newYorkToBoston = 353.4

        if distance >= earthCircumference {
            let times = Int(round(distance / earthCircumference))
            body.append(
                "That's \(times) times around the Earth!"
            )
        } else if distance >= newYorkToBoston / 2 {
            let times = Int(round(distance / newYorkToBoston))
            body.append(
                "That's \(times) times from Boston to New York!"
            )
        }

        return [
            TextInfo(
                id: "distance",
                link: .none,
                heading: "Travelled \(distanceRounded) km",
                status: .passedThrough,
                body: body
            )
        ]
    }

    static func countries(model: DomainModel, year: Int?, linkToCountries: Bool = true) -> [TextInfo] {
        let countries = model.countriesForYear(year)
        return [
            TextInfo(
                id: "countries",
                link: linkToCountries ? .countries : .none,
                heading: "\(countries.count) countries",
                status: .passedThrough,
                body: statusDescriptions(places: model.countriesForYear(year), year: year)
            )
        ] + additionalItems(countries, model: model, year: year)
    }

    static func cities(model: DomainModel, year: Int?, addLink: Bool = true) -> [TextInfo] {
        let cities = model.citiesForYear(year)
        return [
            TextInfo(
                id: "cities",
                link: addLink ? .cities : .none,
                heading: "\(cities.count) cities",
                status: .passedThrough,
                body: statusDescriptions(places: cities, year: year)
            )
        ] + additionalItems(cities, model: model, year: year)
    }

    static func continents(model: DomainModel, year: Int?, addLink: Bool = true) -> [TextInfo] {
        let continents = model.continentsForYear(year)
        let info = TextInfo(
            id: "continents",
            link: addLink ? .continents : .none,
            heading: "\(continents.count) continents",
            status: .passedThrough,
            body: statusDescriptions(places: continents, year: year)
        )
        return [
            info
        ] + additionalItems(continents, model: model, year: year)
    }

    static func timezones(model: DomainModel, year: Int?, addLink: Bool = true) -> [TextInfo] {
        let timezones = model.timezonesForYear(year)
        let info = TextInfo(
            id: "timezones",
            link: addLink ? .timezones : .none,
            heading: "\(timezones.count) timezones",
            status: .passedThrough,
            body: statusDescriptions(places: model.timezonesForYear(year), year: year)
        )
        return [
            info
        ] + additionalItems(timezones, model: model, year: year)
    }
    
    private static func additionalItems<T: Trippable>(_ places: [T], model: DomainModel, year: Int?) -> [TextInfo] {
        var textInfos: [TextInfo] = []

        var remainingPlaces = places
        if let mostVisitedCountry = T.selectLongestStay(places, year: year) {
            textInfos.append(mostVisitedCountry.info(year: year))
            remainingPlaces = places.filter { $0.name != mostVisitedCountry.name }
        }

        if let year = year {
            if let firstYearIn = T.selectFirstYear(remainingPlaces, year: year) {
                textInfos.append(firstYearIn.info(year: year))
            }
        } else {
            if let lastVisited = T.lastVisited(remainingPlaces) {
                textInfos.append(lastVisited.info(year: year))
            }
        }

        return textInfos
    }
    
    private static func statusDescriptions(places: [Trippable], year: Int?) -> [String] {
        var descriptions: [String] = []

        let nativePlaces = places.filter { $0.status(year: year) == .native }
        if nativePlaces.count > 0 {
            descriptions.append(
                "Native in \(nativePlaces.map { $0.name }.joined(separator: ", "))."
            )
        }
        
        let stayedPlaces = places.filter { $0.status(year: year) == .stayed }
        if stayedPlaces.count > 0 {
            descriptions.append(
                "Stayed for a long time in \(stayedPlaces.map { $0.name }.joined(separator: ", "))."
            )
        }
        
        let exploredPlaces = places.filter { $0.status(year: year) == .explored }
        if exploredPlaces.count > 0 {
            descriptions.append(
                "Explored \(exploredPlaces.map { $0.name }.joined(separator: ", "))."
            )
        }
        
        let regularPlaces = places.filter { $0.status(year: year) == .regular }
        if regularPlaces.count > 0 {
            descriptions.append(
                "Regular in \(regularPlaces.map { $0.name }.joined(separator: ", "))."
            )
        }

        let newPlaces = places.filter { $0.status(year: year) == .new }
        if newPlaces.count > 0 {
            descriptions.append(
                "First time in \(newPlaces.map { $0.name }.joined(separator: ", "))."
            )
        }

        return descriptions
    }

}
