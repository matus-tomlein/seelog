//
//  TimezonesBarChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/01/2022.
//  Copyright © 2022 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezonesBarChartView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.timezonesYearCounts } }
    var totalCount: Int { get { return viewState.model.timezonesForYear(nil).count } }

    var body: some View {
        BarChartView(showCounts: true, yearStats: yearStats, total: totalCount)
    }
}

struct TimezonesBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return TimezonesBarChartView()
            .environmentObject(ViewState(model: model))
            .environmentObject(SelectedYearState())
    }
}
