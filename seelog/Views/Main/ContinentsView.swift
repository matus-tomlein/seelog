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
    @ObservedObject var selectedYearState: SelectedYearState
    var model: DomainModel { return viewState.model }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(selectedYear) } }

    var body: some View {
        List {
            Section {
                ContinentsHeatView(selectedYearState: selectedYearState)
            }

            Section(header: Text("\(continents.count) continents")) {
                ContinentsBarChartView(selectedYearState: selectedYearState)
                
                TrippableListView(
                    selectedYearState: selectedYearState,
                    trippables: continents
                )
            }
        }
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentsView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
    }
}
