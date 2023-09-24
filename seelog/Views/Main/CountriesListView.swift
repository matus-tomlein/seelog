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
    var countriesCount: Int { return countries.count }
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }

    var body: some View {
        Section(header: Text("\(countriesCount) countries"  )) {
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
