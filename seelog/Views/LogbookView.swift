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
    var model: DomainModel { return viewState.model }
    var countries: [Country] { get { return model.countriesForYear(year) } }
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
    var continents: [Continent] { get { return model.continentsForYear(year) } }
    var topContinents: [Continent] {
        get {
            Array(continents.sorted(by: { c1, c2 in
                c1.stayDurationForYear(year) > c2.stayDurationForYear(year)
            }).prefix(3))
        }
    }
    var timezones: [Timezone] { get { return model.timezonesForYear(year) } }
    var topTimezones: [Timezone] {
        get {
            Array(timezones.sorted(by: { c1, c2 in
                c1.stayDurationForYear(year) > c2.stayDurationForYear(year)
            }).prefix(3))
        }
    }
    var regions: [Region] { get { return model.regionsForYear(year) } }
    var seenGeometry: SeenGeometry? { get { return model.seenGeometry(year: year, month: 0) } }
    var yearStats: [(year: Int, count: Int)] {
        return model.years.reversed().map { year in
            let distance = year.seenGeometriesByMonth.map { (_, geometry) in
                geometry.travelledDistance
            }.reduce(0, +)

            return (
                year: year.year,
                count: Int(distance)
            )
        }
    }

    var body: some View {
        TabView {
            NavigationView {
                List {
                    VStack(spacing: 0) {
                        WorldView(
                            background: (continents: model.continentInfos, countries: []),
                            foreground: (continents: [], countries: [], regions: [], timezones: []),
                            cities: [],
                            positions: seenGeometry?.higherLevelPositions ?? [],
                            detailed: false,
                            opaque: false
                        )
                        
                        BarChartView(
                            showCounts: true,
                            yearStats: yearStats
                        )
                    }.listRowInsets(EdgeInsets())
                }
                .navigationBarTitle("Seelog")
            }
                .tabItem {
                    Text("Seelog")
                }
            
            NavigationView {
                CountriesView()
            }
                .tabItem {
                    Text("Countries")
                }

            NavigationView {
                ContinentsView()
            }
                .tabItem {
                    Text("Continents")
                }

            NavigationView {
                CitiesView()
            }
                .tabItem {
                    Text("Cities")
                }

            NavigationView {
                TimezonesView()
            }
                .tabItem {
                    Text("Timezones")
                }
        }
//        NavigationView {
//            List {
//                VStack(spacing: 0) {
//                    WorldView(
//                        background: (continents: model.continentInfos, countries: []),
//                        foreground: (continents: [], countries: [], regions: [], timezones: []),
//                        cities: [],
//                        positions: seenGeometry?.higherLevelPositions ?? [],
//                        detailed: false,
//                        opaque: false
//                    )
//
//                    DistanceGridView(
//                        seenGeometries: model.seenGeometriesByYearAndMonth()
//                    )
//                }.listRowInsets(EdgeInsets())
//
//                NavigationLink(destination: CountriesView()) {
//                    VStack(alignment: .leading) {
//                        Text("\(countries.count) countries")
//                            .font(.title)
//                            .fontWeight(.bold)
//                        Text("Show more")
//                    }
//                }
//                .padding(.top, CGFloat(20))
//
//
////                    CountriesHeatView()
//
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(
//                            model.countriesByExplorationStatus(year: year),
//                            id: \.status
//                        ) { (status, countries) in
//                            ForEach(countries) { country in
//                                CountryBadgeView(country: country)
//                            }
//                        }
//                    }
//                }
//
//                NavigationLink(destination: CitiesView()) {
//                    VStack(alignment: .leading) {
//                        Text("\(cities.count) cities")
//                            .font(.title)
//                            .fontWeight(.bold)
//                        Text("Show more")
//                    }
//                }
//                .padding(.top, 20)
//
//                Section(header: Text("Cities")) {
//
//                    ForEach(topCities) { city in
//                        CityListItemView(city: city)
//                    }
//
//                }
//
//                Section(header: Text("Continents")) {
//                    ForEach(topContinents) { continent in
//                        ContinentListItemView(continent: continent)
//                    }
//
//                    NavigationLink(destination: ContinentsView()) {
//                        Text("\(continents.count) continents")
//                            .font(.headline)
//                    }
//                }
//
//                Section(header: Text("Timezones")) {
//
//                    ForEach(topTimezones) { timezone in
//                        TimezoneListItemView(timezone: timezone)
//                    }
//
//                    NavigationLink(destination: TimezonesView()) {
//                        Text("\(timezones.count) timezones")
//                            .font(.headline)
//                    }
//                }
//            }
//            .navigationBarTitle("Seelog")
//        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return LogbookView()
            .environmentObject(ViewState(model: model))
    }
}
