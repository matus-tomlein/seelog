//
//  CountriesBarChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/01/2022.
//  Copyright © 2022 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesBarChartView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.countryYearCounts } }
    var totalCount: Int { get { return viewState.model.countriesForYear(nil).count } }

    var body: some View {
        BarChartView(
            selectedYearState: selectedYearState,
            showCounts: true,
            yearStats: yearStats,
            total: totalCount
        )
    }
}

struct CountriesBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountriesBarChartView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
    }
}
