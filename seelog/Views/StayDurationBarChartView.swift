//
//  StayDurationBarChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StayDurationBarChartView: View {
    var destination: Trippable
    @EnvironmentObject var selectedYearState: SelectedYearState

    var body: some View {
        Section(header: Text("\(destination.stayDurationForYear(selectedYearState.year)) days")) {
            BarChartView(
                showCounts: true,
                yearStats: destination.stayStatsByYear()
            )
            .listRowInsets(EdgeInsets())
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
    }
}

struct StayDurationBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return List {
            StayDurationBarChartView(destination: model.countries[0])
            .environmentObject(SelectedYearState())
        }.previewLayout(.fixed(width: 320, height: 260))
    }
}
