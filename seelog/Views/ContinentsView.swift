//
//  ContinentsView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentsView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    var model: DomainModel { return viewState.model }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(selectedYear) } }
    var continentsCount: Int { return continents.filter { $0.visited(year: selectedYear) }.count }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.continentYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                ContinentsHeatView(selectedYearState: selectedYearState)

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(selectedYearState)
            }.listRowInsets(EdgeInsets())

            ForEach(TextInfoGenerator.continents(model: self.model
            , year: selectedYear, addLink: false)) { textInfo in
                TextInfoView(info: textInfo)
            }

            Section(header: Text("\(continentsCount) continents")) {
                ForEach(continents) { continent in
                    ContinentListItemView(
                        continent: continent,
                        selectedYearState: SelectedYearState()
                    )
                }
            }
        }
        .navigationBarTitle("Continents")
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentsView().environmentObject(ViewState(model: model))
    }
}
