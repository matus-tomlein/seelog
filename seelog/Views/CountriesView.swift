//
//  ContentView.swift
//  seelog
//
//  Created by Matus Tomlein on 28/12/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryVisitStat: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}

struct CountriesView: View {
    var countries: [Country]
    var yearStats: [(year: Int, count: Int)]
    var selectedYear: Int?
    var mapView = MapView(world: true)
    
    var body: some View {
        NavigationView {
            List {
                VStack(spacing: 0) {
                    CountriesMapView(countries: countries, mapView: mapView)
                        .frame(height: CGFloat(300))
                        .listRowInsets(EdgeInsets())

                    BarChartView(yearStats: yearStats, selectedYear: selectedYear)
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom, 20)
                        .padding(.top, 20)
                }.listRowInsets(EdgeInsets())

                Section(header: Text("\(countries.count) countries")) {
                    ForEach(countries) { country in
                        NavigationLink(destination: CountryView(country: country, selectedYear: self.selectedYear)) {
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
        }

    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountriesView(
            countries: model.countriesForYear(2019),
            yearStats: model.countryYearCounts,
            selectedYear: 2019
        )
    }
}
