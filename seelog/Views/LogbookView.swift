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

    var body: some View {
        List {
            VStack(spacing: 0) {
                WorldView(
                    background: (continents: model.continentInfos, countries: [], regions: []),
                    foreground: (continents: [], countries: [], regions: [], timezones: []),
                    cities: [],
                    positions: seenGeometry?.higherLevelPositions ?? [],
                    detailed: false,
                    opaque: false,
                    showPositionsAsDots: true
                )

                BarChartView(
                    showCounts: true,
                    yearStats: yearStats
                )
                    .environmentObject(selectedYearState)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
            }.listRowInsets(EdgeInsets())

            ForEach(TextInfoGenerator.travelledDistance(model: self.model
            , year: year)) { textInfo in
                TextInfoView(info: textInfo)
            }
            
            Section(header: Text("Countries")) {
                ForEach(TextInfoGenerator.countries(model: self.model
                , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
            
            Section(header: Text("Cities")) {
                ForEach(TextInfoGenerator.cities(model: self.model
                , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
            
            Section(header: Text("Continents")) {
                ForEach(TextInfoGenerator.continents(model: self.model
                , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
            
            Section(header: Text("Timezones")) {
                ForEach(TextInfoGenerator.timezones(model: self.model
                , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
        }
        .navigationBarTitle("Hey Explorer!")
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return LogbookView().environmentObject(ViewState(model: model))
    }
}
