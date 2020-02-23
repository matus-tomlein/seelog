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
    var topCountries: [Country] {
        get {
            Array(countries.sorted(by: { c1, c2 in
                c1.stayDurationForYear(year) > c2.stayDurationForYear(year)
            }).prefix(3))
        }
    }
    var cities: [City] { get { return viewState.model.citiesForYear(year) } }
    var topCities: [City] {
        get {
            Array(cities.sorted(by: { c1, c2 in
                c1.stayDurationForYear(year) > c2.stayDurationForYear(year)
            }).prefix(3))
        }
    }
    var continents: [Continent] { get { return viewState.model.continentsForYear(year) } }
    var topContinents: [Continent] {
        get {
            Array(continents.sorted(by: { c1, c2 in
                c1.stayDurationForYear(year) > c2.stayDurationForYear(year)
            }).prefix(3))
        }
    }
    var timezones: [Timezone] { get { return viewState.model.timezonesForYear(year) } }
    var topTimezones: [Timezone] {
        get {
            Array(timezones.sorted(by: { c1, c2 in
                c1.stayDurationForYear(year) > c2.stayDurationForYear(year)
            }).prefix(3))
        }
    }
    var regions: [Region] { get { return viewState.model.regionsForYear(year) } }
    var seenGeometry: SeenGeometry? { get { return viewState.model.seenGeometryForYear(year) } }

    var body: some View {
        NavigationView {
            List {
                VStack(spacing: 0) {
//                    PolygonView(
//                        shapes: viewState.model.continentInfos.map { continent in
//                        (
//                            geometry: continent.geometry,
//                            color: .gray
//                        )
//                        },
//                        points: seenGeometry?.positions.map({pos in
//                            (
//                                lat: pos.lat,
//                                lng: pos.lng,
//                                color: Color.red
//                            )
//                        }) ?? []
//                    ).frame(height: 370, alignment: Alignment.bottom)

                    BarChartView(showCounts: false, yearStats: yearStats)
                        .padding(.bottom, 20)
                        .padding(.top, 20)
                        .environmentObject(viewState)
                }.listRowInsets(EdgeInsets())

                Section(header: Text("Countries")) {
                    CountriesHeatView()

                    NavigationLink(destination: CountriesView()) {
                        Text("\(countries.count) countries and \(regions.count) regions")
                            .font(.headline)
                    }

                    ForEach(topCountries) { country in
                        CountryListItemView(country: country)
                    }
                }
                
                Section(header: Text("Cities")) {
                    CitiesHeatView()

                    NavigationLink(destination: CitiesView()) {
                        Text("\(cities.count) cities")
                            .font(.headline)
                    }
                    
                    ForEach(topCities) { city in
                        CityListItemView(city: city)
                    }
                }

                Section(header: Text("Continents")) {
                    ContinentsHeatView()

                    NavigationLink(destination: ContinentsView()) {
                        Text("\(continents.count) continents")
                            .font(.headline)
                    }
                    
                    ForEach(topContinents) { continent in
                        ContinentListItemView(continent: continent)
                    }
                }

                Section(header: Text("Timezones")) {
                    TimezoneHeatView()

                    NavigationLink(destination: TimezonesView()) {
                        Text("\(timezones.count) timezones")
                            .font(.headline)
                    }
                    
                    ForEach(topTimezones) { timezone in
                        TimezoneListItemView(timezone: timezone)
                    }
                }
            }
            .navigationBarTitle("Seelog")
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
