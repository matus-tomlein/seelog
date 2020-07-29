//
//  CityView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CityView: View {
    var city: City
    @EnvironmentObject var viewState: ViewState
    var year: Int? { return viewState.selectedYear }

    var body: some View {
        List {
            city.region.map { region in
                WorldView(
                    background: (continents: [], countries: [], regions: [region.stateInfo]),
                    foreground: (continents: [], countries: [], regions: [], timezones: []),
                    cities: [city.cityInfo],
                    positions: region.positions(year: year),
                    detailed: true,
                    opaque: false
                )
            }

            StayDurationBarChartView(destination: city)
            TextInfoView(info: city.info(year: year), addHeading: false)
            ContinentListItemView(continent: city.continent)
            CountryListItemView(country: city.country)
            city.region.map { region in
                StateListItemView(region: region)
            }
//            TripsListView(destination: city)
        }
        .navigationBarTitle(city.cityInfo.name)
    }
}

struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CityView(city: model.cities[0])
            .environmentObject(ViewState(model: model))
    }
}
