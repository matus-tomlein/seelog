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
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { return selectedYearState.year }
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
                .environmentObject(selectedYearState)
            TextInfoView(info: country.info(year: year), addHeading: false)
            ContinentListItemView(
                continent: country.continent,
                selectedYearState: selectedYearState
            )

            StatesListView(
                states: regions,
                selectedYearState: selectedYearState
            )
            CitiesListView(
                cities: cities,
                selectedYearState: selectedYearState
            )
//            TripsListView(destination: country)
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
        .environmentObject(SelectedYearState())
    }
}
