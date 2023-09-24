//
//  CitiesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CitiesListView: View {
    var cities: [City]
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var citiesCount: Int { return cities.filter { $0.visited(year: selectedYear) }.count }
    var selectedYear: Int? { get { return selectedYearState.year } }
    var showCount: Bool = true
    var customTitle: String? = nil
    var title: String { return customTitle ?? (showCount ? "\(citiesCount) cities" : "All cities") }
    
    var body: some View {
        Section(header: Text(title)) {
            TrippableListView(
                selectedYearState: selectedYearState,
                trippables: cities
            )
        }
    }
}

struct CitiesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return List {
            CitiesListView(
                cities: model.cities,
                selectedYearState: SelectedYearState()
            ).environmentObject(ViewState(model: model))
        }
    }
}
