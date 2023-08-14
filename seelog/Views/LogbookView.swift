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
                CountriesBarChartView()
                    .environmentObject(selectedYearState)
                
                ForEach(TextInfoGenerator.countriesHome(model: self.model, year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
            
            Section(header: Text("Cities")) {
                CitiesBarChartView()
                    .environmentObject(selectedYearState)
                
                ForEach(TextInfoGenerator.citiesHome(model: self.model
                , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
            
            Section(header: Text("Continents")) {
                ContinentsBarChartView()
                    .environmentObject(selectedYearState)
                ForEach(TextInfoGenerator.continentsHome(model: self.model
                , year: year)) { textInfo in
                    TextInfoView(info: textInfo)
                }
            }
            
            Section(header: Text("Timezones")) {
                TimezonesBarChartView()
                    .environmentObject(selectedYearState)
                ForEach(TextInfoGenerator.timezonesHome(model: self.model
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
