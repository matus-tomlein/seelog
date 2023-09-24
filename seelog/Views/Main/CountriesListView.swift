//
//  CountriesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesListView: View {
    var countries: [Country]
    var countriesCount: Int { return countries.filter { $0.visited(year: selectedYear) }.count }
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }
    var showCount: Bool = true
    var customTitle: String? = nil
    var title: String { return customTitle ?? (showCount ? "\(countriesCount) countries" : "All countries") }

    var body: some View {
        Section(header: Text(title)) {
            TrippableListView(
                selectedYearState: selectedYearState,
                trippables: countries
            )
        }
    }
}

struct CountriesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return List {
            CountriesListView(
                countries: model.countries,
                selectedYearState: SelectedYearState()
            )
                .environmentObject(ViewState(model: model))
        }
    }
}
