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
    
    @State private var tab = 0

    var body: some View {
        Group {
            switch tab {
            case 1: PlacesView()
            case 2: ContinentsView()
            case 3: TimezonesView()
            default: CountriesView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("What is your favorite color?", selection: $tab) {
                    Text("Countries").tag(0)
                    Text("Places").tag(1)
                    Text("Continents").tag(2)
                    Text("Timezones").tag(3)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return LogbookView().environmentObject(ViewState(model: model))
    }
}
