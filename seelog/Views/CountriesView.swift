//
//  CountriesStatsView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var countries: [Country] { get { return viewState.model.countriesForYear(selectedYear) } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.countryYearCounts } }
    
    var body: some View {
        NavigationView {
            List {
                VStack(spacing: 0) {
                    PolygonView(
                        shapes: viewState.model.continentInfos.map { continent in
                            (
                                geometry: continent.geometry,
                                color: .gray
                            )
                            } + countries.map { country in
                                (
                                    geometry: country.countryInfo.geometry110m,
                                    color: .red
                                )
                        },
                        points: []
                    ).frame(height: 370, alignment: Alignment.bottom)

                    BarChartView(yearStats: yearStats)
                        .padding(.bottom, 20)
                        .padding(.top, 20)
                        .environmentObject(viewState)
                }.listRowInsets(EdgeInsets())

                Section(header: Text("\(countries.count) countries")) {
                    ForEach(countries) { country in
                        NavigationLink(destination: CountryView(country: country)
                            .environmentObject(self.viewState)
                        ) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(country.countryInfo.name)
                                    .font(.headline)
                                Text("\(country.stayDurationForYear(self.selectedYear)) days")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Countries")
            .navigationBarHidden(true)
        }

    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountriesView().environmentObject(ViewState(model: model))
    }
}
