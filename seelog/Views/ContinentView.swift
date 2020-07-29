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
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { return selectedYearState.year }
    var countries: [Country] { return continent.countries }
    var countriesForYear: [Country] { return continent.countriesForYear(year) }
    var cities: [City] { return continent.cities }
    var citiesForYear: [City] { return continent.citiesForYear(year) }

    var body: some View {
        List {
            WorldView(
                background: (continents: [continent.continentInfo], countries: [], regions: []),
                foreground: (continents: [], countries: countriesForYear.map { $0.countryInfo }, regions: [], timezones: []),
                cities: citiesForYear.map { $0.cityInfo },
                positions: [],
                detailed: false,
                opaque: false
            )

            StayDurationBarChartView(destination: continent)
                .environmentObject(selectedYearState)
            TextInfoView(info: continent.info(year: year), addHeading: false)
            CountriesListView(
                countries: countries,
                selectedYearState: selectedYearState
            )
            CitiesListView(
                cities: cities,
                selectedYearState: selectedYearState
            )
//            TripsListView(destination: continent)
        }
        .navigationBarTitle(continent.continentInfo.name)
    }
}

struct ContinentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentView(continent: model.continents[3])
            .environmentObject(ViewState(model: model))
    }
}
