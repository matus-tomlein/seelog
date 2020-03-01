//
//  CountryView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryView: View {
    var country: Country
    @EnvironmentObject var viewState: ViewState
    var year: Int? { return viewState.selectedYear }
    var cities: [City] { return country.citiesForYear(year: self.year) }
    var regions: [Region] { return country.statesForYear(year: self.year) }

    var body: some View {
        List {
            WorldView(
                background: (continents: [], countries: [country.countryInfo]),
                foreground: (continents: [], countries: [], regions: regions.map { $0.stateInfo }, timezones: []),
                cities: cities.map { $0.cityInfo },
                detailed: true,
                opaque: false
            )

            StayDurationBarChartView(destination: country)
            ContinentListItemView(continent: country.continent)

            StatesListView(states: regions)
            CitiesListView(cities: cities)
            TripsListView(destination: country)
        }
        .navigationBarTitle(country.countryInfo.name)
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountryView(
            country: model.countries.first(where: { $0.countryInfo.name == "Slovakia" })!
        ).environmentObject(ViewState(model: model))
    }
}
