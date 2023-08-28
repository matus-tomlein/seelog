//
//  CountriesHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesHeatView: View {
    @EnvironmentObject var viewState: ViewState
    var year: Int?
    var countries: [Country] { get { return viewState.model.countriesForYear(year) } }

    var body: some View {
        NavigationLink(destination: DrawablesMapView(drawables: viewState.model.countriesForYear(year))) {
            WorldView(
                background: (continents: viewState.model.continentInfos, countries: [], regions: []),
                foreground: (continents: [], countries: countries.map { $0.countryInfo }, regions: [], timezones: []),
                cities: [],
                positions: [],
                detailed: false,
                opaque: false
            )
        }
    }
}

struct CountriesHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountriesHeatView().environmentObject(ViewState(model: model)).environmentObject(SelectedYearState())
    }
}
