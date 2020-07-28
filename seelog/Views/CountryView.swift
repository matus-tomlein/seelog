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
    var cities: [City] { return country.cities }
    var citiesForYear: [City] { return country.citiesForYear(year: year) }
    var regions: [Region] { return country.regions }
    var regionsForYear: [Region] { return country.regionsForYear(year) }

    var body: some View {
        List {
            WorldView(
                background: (continents: [], countries: [country.countryInfo], regions: []),
                foreground: (continents: [], countries: [], regions: regionsForYear.map { $0.stateInfo }, timezones: []),
                cities: citiesForYear.map { $0.cityInfo },
                positions: country.positions(year: year),
                detailed: true,
                opaque: false
            )

            StayDurationBarChartView(destination: country)
            TextInfoView(info: country.info(year: year), addHeading: false)
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
        let model = simulatedDomainModel()
        
        return CountryView(
            country: model.countries.first(where: { $0.countryInfo.name == "Hungary" })!
        ).environmentObject(ViewState(model: model))
    }
}
