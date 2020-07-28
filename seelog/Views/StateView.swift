//
//  StateView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StateView: View {
    var state: Region
    @EnvironmentObject var viewState: ViewState
    var year: Int? { return viewState.selectedYear }
    var cities: [City] { return state.cities }
    var citiesForYear: [City] { return state.citiesForYear(year: year) }
    
    var body: some View {
        List {
            WorldView(
                background: (continents: [], countries: [state.country.countryInfo], regions: []),
                foreground: (continents: [], countries: [], regions: [state.stateInfo], timezones: []),
                cities: citiesForYear.map { $0.cityInfo },
                positions: state.positions(year: year),
                detailed: true,
                opaque: false,
                zoomIn: true
            )
            
            StayDurationBarChartView(destination: state)
            TextInfoView(info: state.info(year: year), addHeading: false)
            ContinentListItemView(continent: state.continent)
            CountryListItemView(country: state.country)
            CitiesListView(cities: cities)
            TripsListView(destination: state)
        }
        .navigationBarTitle(state.stateInfo.name)
    }
}

struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return StateView(state: model.states[11])
            .environmentObject(ViewState(model: model))
    }
}
