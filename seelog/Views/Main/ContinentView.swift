//
//  ContinentView.swift
//  seelog
//
//  Created by Matus Tomlein on 22/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentView: View {
    var continent: Continent
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { return selectedYearState.year }
    var countries: [Country] { return continent.countriesForYear(year) }
    var cities: [City] { return continent.citiesForYear(year) }

    var body: some View {
        List {
            NavigationLink(destination: ContinentMapView(
                selectedYearState: selectedYearState,
                year: year,
                continent: continent
            )) {
                WorldView(
                    background: (continents: [continent.continentInfo], countries: [], regions: []),
                    foreground: (continents: [], countries: countries.map { $0.countryInfo }, regions: [], timezones: []),
                    cities: cities.map { $0.cityInfo },
                    positions: [],
                    detailed: false,
                    opaque: false
                )
            }
            
            StayDurationBarChartView(destination: continent)
                .environmentObject(selectedYearState)
            
            if !countries.isEmpty {
                CountriesListView(
                    countries: countries,
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
        .navigationBarTitle(continent.nameWithFlag)
    }
}

struct ContinentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentView(
            continent: model.continents[3],
            selectedYearState: SelectedYearState()
        )
            .environmentObject(ViewState(model: model))
    }
}
