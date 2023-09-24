//
//  TimezonesView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezonesView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var model: DomainModel { return viewState.model }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var timezones: [Timezone] { get { return viewState.model.timezonesForYear(selectedYear) } }
    var timezonesCount: Int { return timezones.filter { $0.visited(year: selectedYear) }.count }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.timezonesYearCounts } }

    var body: some View {
        List {
            Section {
                TimezoneHeatView(selectedYearState: selectedYearState)
            }

            Section(header: Text("\(timezones.count) timezones")) {
                TimezonesBarChartView(selectedYearState: SelectedYearState())

                TrippableListView(
                    selectedYearState: selectedYearState,
                    trippables: timezones
                )
            }
        }
    }
}

struct TimezonesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return TimezonesView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
    }
}
