//
//  ContinentView.swift
//  seelog
//
//  Created by Matus Tomlein on 22/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentView: View {
    var continent: Continent
    @EnvironmentObject var viewState: ViewState
    var year: Int? { return viewState.selectedYear }
    var countries: [Country] { return continent.countriesForYear(year: year) }
    var cities: [City] { return continent.citiesForYear(year: year) }

    var body: some View {
        List {
            WorldView(
                background: (continents: [continent.continentInfo], countries: []),
                foreground: (continents: [], countries: countries.map { $0.countryInfo }, regions: [], timezones: []),
                cities: cities.map { $0.cityInfo },
                detailed: false,
                opaque: false
            )

            StayDurationBarChartView(destination: continent)
            CountriesListView(countries: countries)
            CitiesListView(cities: cities)
            TripsListView(destination: continent)
        }
        .navigationBarTitle(continent.continentInfo.name)
    }
}

struct ContinentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return ContinentView(continent: model.continents[3])
            .environmentObject(ViewState(model: model))
    }
}
