//
//  TimezoneView.swift
//  seelog
//
//  Created by Matus Tomlein on 22/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezoneView: View {
    var timezone: Timezone
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { return selectedYearState.year }

    var body: some View {
        List {
            WorldView(
                background: (continents: viewState.model.continentInfos, countries: [], regions: []),
                foreground: (continents: [], countries: [], regions: [], timezones: [timezone.timezoneInfo]),
                cities: [],
                positions: [],
                detailed: false,
                opaque: true
            )
            
            StayDurationBarChartView(destination: timezone)
                .environmentObject(selectedYearState)
            TextInfoView(info: timezone.info(year: year), addHeading: false)
//            TripsListView(destination: timezone)
        }
        .navigationBarTitle(Text(timezone.timezoneInfo.name), displayMode: .inline)
        .navigationBarItems(trailing: LogbookLinkView())
    }
}

struct TimezoneView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return TimezoneView(
            timezone: model.timezones[0]
        ).environmentObject(ViewState(model: model))
        .environmentObject(SelectedYearState())
    }
}
