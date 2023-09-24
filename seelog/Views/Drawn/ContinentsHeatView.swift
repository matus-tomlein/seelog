//
//  ContinentsHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentsHeatView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(selectedYear) } }

    var body: some View {
        NavigationLink(destination: ContinentsMapView(selectedYearState: selectedYearState)) {
            WorldView(
                background: (continents: viewState.model.continentInfos, countries: [], regions: []),
                foreground: (continents: continents.map { $0.continentInfo }, countries: [], regions: [], timezones: []),
                cities: [],
                positions: [],
                detailed: false,
                opaque: false
            )
        }
    }
}

struct ContinentsHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentsHeatView(
            selectedYearState: SelectedYearState()
        ).environmentObject(ViewState(model: model))
    }
}
