//
//  CitiesView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CitiesView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    var model: DomainModel { return viewState.model }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var cities: [City] { get { return viewState.model.cities } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.cityYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                CitiesHeatView(selectedYearState: selectedYearState)

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(selectedYearState)
            }.listRowInsets(EdgeInsets())

            ForEach(TextInfoGenerator.cities(model: self.model
            , year: selectedYear, addLink: false)) { textInfo in
                TextInfoView(info: textInfo)
            }

            CitiesListView(
                cities: cities,
                selectedYearState: selectedYearState
            )
        }
        .navigationBarTitle("Cities")
    }
}

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CitiesView().environmentObject(ViewState(model: model))
    }
}
