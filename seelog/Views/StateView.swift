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
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { return selectedYearState.year }
    var cities: [City] { return state.citiesForYear(year: year) }
    
    var body: some View {
        List {
            WorldView(
                background: (continents: [], countries: [state.country.countryInfo], regions: []),
                foreground: (continents: [], countries: [], regions: [state.stateInfo], timezones: []),
                cities: cities.map { $0.cityInfo },
                positions: state.positions(year: year),
                detailed: true,
                opaque: false,
                zoomIn: true
            )
            
            StayDurationBarChartView(destination: state)
                .environmentObject(selectedYearState)
            TextInfoView(info: state.info(year: year), addHeading: false)
            ContinentListItemView(
                continent: state.continent,
                selectedYearState: SelectedYearState()
            )
            CountryListItemView(
                country: state.country,
                selectedYearState: selectedYearState
            )
            CitiesListView(
                cities: cities,
                selectedYearState: selectedYearState
            )
//            TripsListView(destination: state)
        }
        .navigationBarTitle(state.stateInfo.name)
        .navigationBarItems(trailing: LogbookLinkView())
    }
}

struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return StateView(state: model.states[11])
            .environmentObject(ViewState(model: model))
    }
}
