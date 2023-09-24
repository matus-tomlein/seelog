//
//  LogbookView.swift
//  seelog
//
//  Created by Matus Tomlein on 26/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LogbookView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { return selectedYearState.year }
    var model: DomainModel { return viewState.model }

    var seenGeometry: SeenGeometry? { get { return model.seenGeometry(year: year) } }
    var yearStats: [(year: Int, count: Int)] {
        return model.years.reversed().map { year in
            let distance = year.seenGeometry?.travelledDistance ?? 0

            return (
                year: year.year,
                count: Int(distance)
            )
        }
    }
    
    var countriesYearStats: [(year: Int, count: Int)] { get { return viewState.model.countryYearCounts } }
    var citiesYearStats: [(year: Int, count: Int)] { get { return viewState.model.cityYearCounts } }
    var continentsYearStats: [(year: Int, count: Int)] { get { return viewState.model.continentYearCounts } }
    var timezonesYearStats: [(year: Int, count: Int)] { get { return viewState.model.timezonesYearCounts } }
    
    @State private var tab: SelectedTab = .countries

    var body: some View {
        Group {
            switch tab {
            case .places: PlacesView(selectedYearState: selectedYearState)
            case .continents: ContinentsView(selectedYearState: selectedYearState)
            case .timezones: TimezonesView(selectedYearState: selectedYearState)
            case .countries: CountriesView(selectedYearState: selectedYearState)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $tab) {
                    Text("Countries").tag(SelectedTab.countries)
                    Text("Places").tag(SelectedTab.places)
                    Text("Continents").tag(SelectedTab.continents)
                    Text("Timezones").tag(SelectedTab.timezones)
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return LogbookView().environmentObject(ViewState(model: model))
    }
}
