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
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var countries: [Country] { get { return viewState.model.countries } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.countryYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                CountriesHeatView()

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(viewState)
            }.listRowInsets(EdgeInsets())

            ForEach(TextInfoGenerator.countries(model: self.viewState.model
            , year: selectedYear, linkToCountries: false)) { textInfo in
                TextInfoView(info: textInfo)
            }

            CountriesListView(countries: countries)
        }
        .navigationBarTitle("Countries")

    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountriesView().environmentObject(ViewState(model: model))
    }
}
