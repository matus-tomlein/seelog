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
    var detailed: Bool
    var opaque: Bool
    
    var backgroundGeometries: [Geometry?] {
        return background.continents.map { continent in
            continent.geometry
        } + background.countries.map {country in
            detailed ? country.geometry10m : country.geometry110m
        }
    }
    var foregroundGeometries: [Geometry?] {
        return foreground.continents.map { continent in
            continent.geometry
        } + foreground.countries.map { country in
            detailed ? country.geometry10m : country.geometry110m
        } + foreground.regions.map { region in
            detailed ? region.geometry10m : region.geometry110m
        } + foreground.timezones.map { timezone in
            timezone.geometry
        }
    }
    var foregroundColor: Color {
        opaque ? Color.red.opacity(0.5) : Color.red
    }

    var body: some View {
        PolygonView(
            shapes: backgroundGeometries.map { geometry in
                (
                    geometry: geometry,
                    color: .gray
                )
            } + foregroundGeometries.map { geometry in
                (
                    geometry: geometry,
                    color: foregroundColor
                )
            },
            points: cities.map { city in
                (
                    lat: city.latitude,
                    lng: city.longitude,
                    color: .blue
                )
            }
        ).frame(height: 300, alignment: Alignment.bottom)
    }
}

struct WorldView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return WorldView(
            background: (continents: model.continents.map {$0.continentInfo}, countries: []),
            foreground: (continents: [], countries: model.countries.map {$0.countryInfo}, regions: [], timezones: []),
            cities: model.cities.map {$0.cityInfo},
            detailed: false,
            opaque: false
        )
    }
}
