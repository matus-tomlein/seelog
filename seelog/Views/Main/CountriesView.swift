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
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { get { return selectedYearState.year } }
    var countries: [Country] {
        return viewState.model.countriesForYear(year)
    }
    
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Section {
                CountriesHeatView(selectedYearState: selectedYearState)
            }
            
            Section(header: Text("\(countries.count) countries")) {
                CountriesBarChartView(selectedYearState: selectedYearState)
                
                TrippableListView(
                    selectedYearState: selectedYearState,
                    trippables: countries
                )
            }
        }
    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountriesView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
            .environmentObject(SelectedYearState())
    }
}
