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
                
                let distance = travelledDistanceInfo(
                    model: self.model,
                    year: year
                )
                Text(distance.heading)
                    .font(.headline)
                Text(distance.body)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            
            CitiesListView(cities: cities, selectedYearState: selectedYearState)
        }
    }
    
    private func travelledDistanceInfo(model: DomainModel, year: Int?) -> (heading: String, body: String) {
        var body = ""
        let distanceRounded = model.seenGeometry(year: year)?.travelledDistanceRounded ?? 0
        let distance = model.seenGeometry(year: year)?.travelledDistance ?? 0
        let earthCircumference = 40075.0
        let newYorkToBoston = 353.4

        if distance >= earthCircumference {
            let times = Int(round(distance / earthCircumference))
            body =
                "That's \(format(times)) times around the Earth!"
        } else if distance >= newYorkToBoston / 2 {
            let times = Int(round(distance / newYorkToBoston))
            body = "That's \(format(times)) times from Boston to New York!"
        }

        return (
            heading: "Travelled \(format(distanceRounded)) km",
            body: body
        )
    }

    private func format(_ number: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: number), number: NumberFormatter.Style.decimal)
    }
}

struct PlacesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return PlacesView(selectedYearState: SelectedYearState())
            .environmentObject(ViewState(model: model))
    }
}
