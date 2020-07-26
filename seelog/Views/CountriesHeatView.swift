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
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var countries: [Country] { get { return viewState.model.countriesForYear(selectedYear) } }

    var body: some View {
        WorldView(
            background: (continents: viewState.model.continentInfos, countries: []),
            foreground: (continents: [], countries: countries.map { $0.countryInfo }, regions: [], timezones: []),
            cities: [],
            positions: [],
            detailed: false,
            opaque: false
        )
    }
}

struct CountriesHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountriesHeatView().environmentObject(ViewState(model: model))
    }
}
