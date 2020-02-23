//
//  LogbookView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LogbookView: View {
    @EnvironmentObject var viewState: ViewState
    var year: Int? { get { return viewState.selectedYear } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.totalYearCounts } }
    var countries: [Country] { get { return viewState.model.countriesForYear(year) } }
    var cities: [City] { get { return viewState.model.citiesForYear(year) } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(year) } }
    var timezones: [Timezone] { get { return viewState.model.timezonesForYear(year) } }
    var regions: [Region] { get { return viewState.model.regionsForYear(year) } }

    var body: some View {
        NavigationView {
            List {
                BarChartView(showCounts: false, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(viewState)

                Section(header: Text("Countries")) {
                    NavigationLink(destination: CountriesView()) {
                        Text("\(countries.count) countries and \(regions.count) regions")
                    }
                }
                
                Section(header: Text("Cities")) {
                    NavigationLink(destination: CitiesView()) {
                        Text("\(cities.count) cities")
                    }
                }

                Section(header: Text("Continents")) {
                    NavigationLink(destination: ContinentsView()) {
                        Text("\(continents.count) continents")
                    }
                }

                Section(header: Text("Timezones")) {
                    NavigationLink(destination: TimezonesView()) {
                        Text("\(timezones.count) timezones")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return LogbookView()
            .environmentObject(ViewState(model: model))
    }
}
