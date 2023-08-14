//
//  CountriesStatsView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    var selectedYear: Int? { get { return selectedYearState.year } }
    var countries: [Country] { get { return viewState.model.countriesForYear(selectedYear) } }
    
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            VStack(spacing: 0) {
                CountriesHeatView()
                    .environmentObject(selectedYearState)

                CountriesBarChartView()
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(selectedYearState)
            }.listRowInsets(EdgeInsets())

            ForEach(TextInfoGenerator.countries(model: self.viewState.model
            , year: selectedYear, linkToCountries: false)) { textInfo in
                TextInfoView(info: textInfo)
            }

            CountriesListView(
                countries: countries,
                selectedYearState: selectedYearState,
                showCount: false
            )
        }
        .navigationBarTitle("Countries")

    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountriesView().environmentObject(ViewState(model: model))
            .environmentObject(SelectedYearState())
    }
}
