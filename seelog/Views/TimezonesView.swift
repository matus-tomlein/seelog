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
    @ObservedObject var selectedYearState = SelectedYearState()
    var model: DomainModel { return viewState.model }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var timezones: [Timezone] { get { return viewState.model.timezones } }
    var timezonesCount: Int { return timezones.filter { $0.visited(year: selectedYear) }.count }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.timezonesYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                TimezoneHeatView(selectedYearState: selectedYearState)

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(selectedYearState)
            }.listRowInsets(EdgeInsets())

            ForEach(TextInfoGenerator.timezones(model: self.model
            , year: selectedYear, addLink: false)) { textInfo in
                TextInfoView(info: textInfo)
            }

            Section(header: Text("\(timezonesCount) timezones")) {
                ForEach(timezones) { timezone in
                    TimezoneListItemView(
                        timezone: timezone,
                        selectedYearState: self.selectedYearState
                    )
                }
            }
        }
        .navigationBarTitle("Timezones")

    }
}

struct TimezonesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return TimezonesView().environmentObject(ViewState(model: model))
    }
}
