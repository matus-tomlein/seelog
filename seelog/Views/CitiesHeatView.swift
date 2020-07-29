//
//  CitiesHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CitiesHeatView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }
    var cities: [City] { get { return viewState.model.citiesForYear(selectedYear) } }

    var body: some View {
        WorldView(
            background: (continents: viewState.model.continentInfos, countries: [], regions: []),
            foreground: (continents: [], countries: [], regions: [], timezones: []),
            cities: cities.map { $0.cityInfo },
            positions: [],
            detailed: false,
            opaque: true
        )
    }
}

struct CitiesHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CitiesHeatView(
            selectedYearState: SelectedYearState()
        ).environmentObject(ViewState(model: model))
    }
}
