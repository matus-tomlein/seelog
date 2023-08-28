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
    @ObservedObject var selectedYearState = SelectedYearState()
    var year: Int? { get { return selectedYearState.year } }
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
    
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            VStack(spacing: 0) {
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

                BarChartView(
                    showCounts: true,
                    yearStats: yearStats
                )
                    .environmentObject(selectedYearState)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
            }.listRowInsets(EdgeInsets())

            Section {
                ForEach(TextInfoGenerator.travelledDistance(model: self.model
                                                            , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
        }
    }
}

struct PlacesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return PlacesView().environmentObject(ViewState(model: model))
            .environmentObject(SelectedYearState())
    }
}
