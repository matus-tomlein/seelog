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
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(selectedYear) } }

    var body: some View {
        WorldView(
            background: (continents: viewState.model.continentInfos, countries: []),
            foreground: (continents: continents.map { $0.continentInfo }, countries: [], regions: [], timezones: []),
            cities: [],
            positions: [],
            detailed: false,
            opaque: false
        )
    }
}

struct ContinentsHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentsHeatView().environmentObject(ViewState(model: model))
    }
}
