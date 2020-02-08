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
    
    var body: some View {
        List {
            MapView()
//                    .edgesIgnoringSafeArea(.top)
                .frame(height: CGFloat(300))
                .listRowInsets(EdgeInsets())

            Text("\(countries.count) Countries")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .padding(.top, 20)

            BarChartView(yearStats: yearStats)
                .listRowInsets(EdgeInsets())
                .padding(.bottom, 20)

            Section(header: Text("Visited Countries")) {
                ForEach(countries) { country in
                    Text(country.countryInfo.name)
                }
            }
        }

        .edgesIgnoringSafeArea(.top)
    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), geoDatabase: GeoDatabase())
        
        return CountriesView(
            countries: model.countries,
            yearStats: model.countryYearCounts
        )
    }
}
