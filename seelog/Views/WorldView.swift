//
//  WorldView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct WorldView: View {
    var background: (continents: [ContinentInfo], countries: [CountryInfo], regions: [StateInfo])
    var foreground: (continents: [ContinentInfo], countries: [CountryInfo], regions: [StateInfo], timezones: [TimezoneInfo])
    var cities: [CityInfo]
    var positions: [Location]
    var detailed: Bool
    var opaque: Bool
    var zoomIn: Bool = false
    var showPositionsAsDots = false

    var backgroundGeometries: [GeometryDescription] {
        return background.continents.map { continent in
            continent.geometryDescription
        } + background.countries.map {country in
            detailed ? country.geometry10mDescription : country.geometry110mDescription
        } + background.regions.map { region in
            detailed ? region.geometry10mDescription : region.geometry110mDescription
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
    var backgroundShapes: [(geometryDescription: GeometryDescription, color: Color, opacity: Double)] {
        backgroundGeometries.map { geometry in
            (
                geometryDescription: geometry,
                color: .gray,
                opacity: 1
            )
        }
    }
    var foregroundShapes: [(geometryDescription: GeometryDescription, color: Color, opacity: Double)] {
        foregroundGeometries.map { geometry in
            (
                geometryDescription: geometry,
                color: foregroundColor,
                opacity: 1
            )
        }
    }
    var shapes: [(geometryDescription: GeometryDescription, color: Color, opacity: Double)] {
        backgroundShapes + foregroundShapes
    }
    var bounds: (minX: Double, maxX: Double, minY: Double, maxY: Double, scale: CGFloat) {
        let shapesToUse = (zoomIn && foregroundGeometries.count > 0) ? foregroundShapes : shapes

        let minX = shapesToUse.map { $0.geometryDescription.minX }.min() ?? 0
        var minY = shapesToUse.map { $0.geometryDescription.minY }.min() ?? 0
        let maxX = shapesToUse.map { $0.geometryDescription.maxX }.max() ?? 0
        var maxY = shapesToUse.map { $0.geometryDescription.maxY }.max() ?? 0

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
    var points: [(x: Double, y: Double, color: Color, size: Double, opacity: Double)] {
        return self.cities.map { city in
            (
                x: Helpers.longitudeToX(city.longitude),
                y: Helpers.latitudeToY(city.latitude),
                color: Color(UIColor.label),
                size: 10,
                opacity: 0.7
            )
        } + (showPositionsAsDots ? self.positions.map { position in
            (
                x: position.x,
                y: position.y,
                color: Color.red,
                size: 5,
                opacity: 0.7
            )
        } : [])
    }

    var body: some View {
        let bounds = self.bounds

        return PolygonView(
            shapes: self.shapes,
            points: self.points,
            rectangles: self.rectangles(
                minX: bounds.minX,
                maxX: bounds.maxX,
                minY: bounds.minY,
                maxY: bounds.maxY
            ),
            minX: bounds.minX,
            maxX: bounds.maxX,
            minY: bounds.minY,
            maxY: bounds.maxY
        ).frame(
            height: UIScreen.main.bounds.size.width * bounds.scale,
            alignment: Alignment.bottom
        )
    }

    func rectangles(minX: Double, maxX: Double, minY: Double, maxY: Double) -> [(x: Double, y: Double, width: Double, height: Double)] {
        return showPositionsAsDots ? [] : self.positions.map {
            $0.toRectangle(
                boundsMinX: minX,
                boundsMaxX: maxX,
                boundsMinY: minY,
                boundsMaxY: maxY
            )
        }
    }
}

struct WorldView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return WorldView(
            background: (continents: model.continentInfos, countries: [], regions: []),
            foreground: (continents: [], countries: model.countries.map {$0.countryInfo}, regions: [], timezones: []),
            cities: model.cities.map {$0.cityInfo},
            positions: [],
            detailed: false,
            opaque: false
        )
    }
}
