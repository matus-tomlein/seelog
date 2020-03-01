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
    var cities: [City] { return state.citiesForYear(year: self.year) }
    
    var body: some View {
        List {
            WorldView(
                background: (continents: [], countries: [state.country.countryInfo]),
                foreground: (continents: [], countries: [], regions: [state.stateInfo], timezones: []),
                cities: cities.map { $0.cityInfo },
                detailed: true,
                opaque: false
            )
            
            StayDurationBarChartView(destination: state)
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
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return StateView(state: model.states[11])
            .environmentObject(ViewState(model: model))
    }
}
