//
//  CountriesStatsView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct PlacesView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { get { return selectedYearState.year } }
    var model: DomainModel { return viewState.model }
    var cities: [City] { return model.citiesForYear(year) }
    
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
    
    var travelledDistance: String {
        return Helpers.formatNumber(seenGeometry?.travelledDistance ?? 0.0)
    }

    var body: some View {
        List {
            Section {
                NavigationLink(destination: PlacesMapView(year: selectedYearState.year)) {
                    WorldView(
                        background: (continents: model.continentInfos, countries: [], regions: []),
                        foreground: (continents: [], countries: [], regions: [], timezones: []),
                        cities: [],
                        positions: seenGeometry?.higherLevelPositions ?? [],
                        detailed: false,
                        opaque: false,
                        showPositionsAsDots: true
                    )
                }
            }

            Section(header: Text("\(travelledDistance) km")) {
                BarChartView(
                    selectedYearState: selectedYearState,
                    showCounts: true,
                    yearStats: yearStats
                )
                
                TextInfoView(info: TextInfoGenerator.travelledDistance(
                    model: self.model,
                    year: year))
            }
            
            CitiesListView(cities: cities, selectedYearState: selectedYearState)
        }
    }
}

struct PlacesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return PlacesView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
    }
}
