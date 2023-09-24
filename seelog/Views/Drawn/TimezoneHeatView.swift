//
//  TimezoneHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezoneHeatView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }
    var timezones: [Timezone] { get { return viewState.model.timezonesForYear(selectedYear) } }

    var body: some View {
        NavigationLink(destination: TimezonesMapView(selectedYearState: selectedYearState)) {
            WorldView(
                background: (continents: viewState.model.continentInfos, countries: [], regions: []),
                foreground: (continents: [], countries: [], regions: [], timezones: timezones.map { $0.timezoneInfo }),
                cities: [],
                positions: [],
                detailed: false,
                opaque: true
            )
        }
    }
}

struct TimezoneHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return TimezoneHeatView(
            selectedYearState: SelectedYearState()
        ).environmentObject(ViewState(model: model))
    }
}
