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
        return [
            TextInfo(
                id: "countries",
                link: linkToCountries ? .countries : .none,
                heading: "\(model.countriesForYear(year).count) countries",
                status: .passedThrough,
                body: statusDescriptions(places: model.countriesForYear(year), year: year)
            )
        ]
    }

    static func cities(model: DomainModel, year: Int?, addLink: Bool = true) -> [TextInfo] {
        return [
            TextInfo(
                id: "cities",
                link: addLink ? .cities : .none,
                heading: "\(model.citiesForYear(year).count) cities",
                status: .passedThrough,
                body: statusDescriptions(places: model.citiesForYear(year), year: year)
            )
        ]
    }

    static func continents(model: DomainModel, year: Int?, addLink: Bool = true) -> [TextInfo] {
        let info = TextInfo(
            id: "continents",
            link: addLink ? .continents : .none,
            heading: "\(model.continentsForYear(year).count) continents",
            status: .passedThrough,
            body: statusDescriptions(places: model.continentsForYear(year), year: year)
        )
        return [
            info
        ]
    }

    static func timezones(model: DomainModel, year: Int?, addLink: Bool = true) -> [TextInfo] {
        let info = TextInfo(
            id: "timezones",
            link: addLink ? .timezones : .none,
            heading: "\(model.timezonesForYear(year).count) timezones",
            status: .passedThrough,
            body: statusDescriptions(places: model.timezonesForYear(year), year: year)
        )
        return [
            info
        ]
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
