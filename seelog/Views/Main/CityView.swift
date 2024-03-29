//
//  CityView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CityView: View {
    var city: City
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { return selectedYearState.year }
    
    var body: some View {
        List {
            city.region.map { region in
                NavigationLink(destination: DrawablesMapView(
                    borderDrawables: [region],
                    drawables: [],
                    cities: [city],
                    selectedYearState: selectedYearState
                )) {
                    WorldView(
                        background: (continents: [], countries: [], regions: [region.stateInfo]),
                        foreground: (continents: [], countries: [], regions: [], timezones: []),
                        cities: [city.cityInfo],
                        positions: region.positions(year: year),
                        detailed: true,
                        opaque: false
                    )
                }
            }

            StayDurationBarChartView(destination: city)
                .environmentObject(selectedYearState)
            
            Section(header: Text("Continent")) {
                TrippableListItemView(
                    trippable: city.continent,
                    selectedYearState: selectedYearState
                )
            }
            Section(header: Text("Country")) {
                TrippableListItemView(
                    trippable: city.country,
                    selectedYearState: selectedYearState
                )
            }
            Section(header: Text("Region")) {
                city.region.map { region in
                    TrippableListItemView(
                        trippable: region,
                        selectedYearState: selectedYearState
                    )
                }
            }
//            TripsListView(destination: city)
        }
        .navigationBarTitle(city.cityInfo.name)
    }
}

struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CityView(
            city: model.cities[0],
            selectedYearState: SelectedYearState()
        )
            .environmentObject(ViewState(model: model))
    }
}
