//
//  CountryView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryView: View {
    var country: Country
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { return selectedYearState.year }
    var cities: [City] { return country.citiesForYear(year: year) }
    var regions: [Region] { return country.regionsForYear(year) }

    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            NavigationLink(destination: DrawablesMapView(
                borderDrawables: [country],
                drawables: regions,
                cities: cities
            )) {
                WorldView(
                    background: (continents: [], countries: [country.countryInfo], regions: []),
                    foreground: (continents: [], countries: [], regions: regions.map { $0.stateInfo }, timezones: []),
                    cities: cities.map { $0.cityInfo },
                    positions: country.positions(year: year),
                    detailed: true,
                    opaque: false
                )
            }

            StayDurationBarChartView(destination: country)
                .environmentObject(selectedYearState)
            
            Section(header: Text("Continent")) {
                ContinentListItemView(
                    continent: country.continent,
                    selectedYearState: selectedYearState
                )
            }

            if !regions.isEmpty {
                StatesListView(
                    states: regions,
                    total: country.countryInfo.numberOfRegions,
                    selectedYearState: selectedYearState
                )
            }
            if !cities.isEmpty {
                CitiesListView(
                    cities: cities,
                    selectedYearState: selectedYearState
                )
            }
        }
        .navigationBarTitle(country.countryInfo.name)
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountryView(
            country: model.countries.first(where: { $0.countryInfo.name == "Hungary" })!
        ).environmentObject(ViewState(model: model))
        .environmentObject(SelectedYearState())
    }
}
