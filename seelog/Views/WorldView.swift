//
//  WorldView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI
import GEOSwift

struct WorldView: View {
    var background: (continents: [ContinentInfo], countries: [CountryInfo])
    var foreground: (continents: [ContinentInfo], countries: [CountryInfo], regions: [StateInfo], timezones: [TimezoneInfo])
    var cities: [CityInfo]
    var positions: [Location]
    var detailed: Bool
    var opaque: Bool

    var backgroundGeometries: [GeometryDescription] {
        return background.continents.map { continent in
            continent.geometryDescription
        } + background.countries.map {country in
            detailed ? country.geometry10mDescription : country.geometry110mDescription
        }
    }
    var foregroundGeometries: [GeometryDescription] {
        return foreground.continents.map { continent in
            continent.geometryDescription
        } + foreground.countries.map { country in
            detailed ? country.geometry10mDescription : country.geometry110mDescription
        } + foreground.regions.map { region in
            detailed ? region.geometry10mDescription : region.geometry110mDescription
        } + foreground.timezones.map { timezone in
            timezone.geometryDescription
        }
    }
    var foregroundColor: Color {
        opaque ? Color.red.opacity(0.5) : Color.red
    }
    var shapes: [(geometryDescription: GeometryDescription, color: Color)] {
        backgroundGeometries.map { geometry in
            (
                geometryDescription: geometry,
                color: .gray
            )
        } + foregroundGeometries.map { geometry in
            (
                geometryDescription: geometry,
                color: foregroundColor
            )
        }
    }
    var bounds: (minX: Double, maxX: Double, minY: Double, maxY: Double, scale: CGFloat) {
        let minX = shapes.map { $0.geometryDescription.minX }.min() ?? 0
        var minY = shapes.map { $0.geometryDescription.minY }.min() ?? 0
        let maxX = shapes.map { $0.geometryDescription.maxX }.max() ?? 0
        var maxY = shapes.map { $0.geometryDescription.maxY }.max() ?? 0

        let globalMaxY = Helpers.latitudeToY(-59)
        let globalMinY = Helpers.latitudeToY(85)
        
        minY = max(globalMinY, minY)
        maxY = min(globalMaxY, maxY)

        return (
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            scale: CGFloat((maxY - minY) / (maxX - minX))
        )
    }
    var points: [(lat: Double, lng: Double, color: Color, size: Double, opacity: Double)] {
        return self.cities.map { city in
            (
                lat: city.latitude,
                lng: city.longitude,
                color: Color(UIColor.label),
                size: 10,
                opacity: 0.7
            )
        } + self.positions.map { position in
            (
                lat: position.lat,
                lng: position.lng,
                color: .red,
                size: 5,
                opacity: 1
            )
        }
    }

    var body: some View {
        let bounds = self.bounds

        return PolygonView(
            shapes: self.shapes,
            points: self.points,
            minX: bounds.minX,
            maxX: bounds.maxX,
            minY: bounds.minY,
            maxY: bounds.maxY
        ).frame(
            height: min(400, UIScreen.main.bounds.size.width * bounds.scale),
            alignment: Alignment.bottom
        )
    }
}

struct WorldView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return WorldView(
            background: (continents: model.continentInfos, countries: []),
            foreground: (continents: [], countries: model.countries.map {$0.countryInfo}, regions: [], timezones: []),
            cities: model.cities.map {$0.cityInfo},
            positions: [],
            detailed: false,
            opaque: false
        )
    }
}
