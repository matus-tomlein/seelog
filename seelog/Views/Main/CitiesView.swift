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
    @ObservedObject var selectedYearState: SelectedYearState
    var model: DomainModel { return viewState.model }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var cities: [City] { get { return viewState.model.citiesForYear(selectedYear) } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                CitiesHeatView(selectedYearState: selectedYearState)

                CitiesBarChartView(selectedYearState: selectedYearState)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
            }.listRowInsets(EdgeInsets())

            CitiesListView(
                cities: cities,
                selectedYearState: selectedYearState,
                showCount: false
            )
        }
        .navigationBarTitle("Cities")
    }
}

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CitiesView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
    }
}
