//
//  CountryView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryView: View {
    var country: Country
    @EnvironmentObject var viewState: ViewState
    var year: Int? { get { return viewState.selectedYear } }

    var body: some View {
        List {
            PolygonView(
                shapes: [
                    (
                        geometry: country.countryInfo.geometry10m,
                        color: .gray
                    )
                ] + country.statesForYear(year: year).map { state in
                    (
                        geometry: state.stateInfo.geometry10m,
                        color: .red
                    )
                },
                points: country.citiesForYear(year: year).map { city in
                    (
                        lat: city.cityInfo.latitude,
                        lng: city.cityInfo.longitude,
                        color: .black
                    )
                }
            ).frame(height: 300, alignment: Alignment.bottom)

            StayDurationBarChartView(destination: country)

            StatesListView(states: country.statesForYear(year: self.year))
            CitiesListView(cities: country.citiesForYear(year: self.year))
            TripsListView(destination: country)
        }
        .navigationBarTitle(country.countryInfo.name)
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountryView(
            country: model.countries.first(where: { $0.countryInfo.name == "Slovakia" })!
        ).environmentObject(ViewState(model: model))
    }
}
