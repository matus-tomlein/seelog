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
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var timezones: [Timezone] { get { return viewState.model.timezonesForYear(selectedYear) } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.timezonesYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                PolygonView(
                    shapes: viewState.model.continentInfos.map { continent in
                        (
                            geometry: continent.geometry,
                            color: .gray
                        )
                        } + timezones.map { timezone in
                            (
                                geometry: timezone.timezoneInfo.geometry,
                                color: Color.red.opacity(0.5)
                            )
                    },
                    points: []
                ).frame(height: 370, alignment: Alignment.bottom)

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(viewState)
            }.listRowInsets(EdgeInsets())

            Section(header: Text("\(timezones.count) timezones")) {
                ForEach(timezones) { timezone in
                    NavigationLink(destination: TimezoneView(timezone: timezone)
                        .environmentObject(self.viewState)
                    ) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(timezone.timezoneInfo.name)
                                .font(.headline)
                            Text("\(timezone.stayDurationForYear(self.selectedYear)) days")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Timezones")

    }
}

struct TimezonesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return TimezonesView().environmentObject(ViewState(model: model))
    }
}
