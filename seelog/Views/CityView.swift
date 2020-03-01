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

    var body: some View {
        List {
            StayDurationBarChartView(destination: city)
            ContinentListItemView(continent: city.continent)
            CountryListItemView(country: city.country)
            city.region.map { region in
                StateListItemView(region: region)
            }
            TripsListView(destination: city)
        }
        .navigationBarTitle(city.cityInfo.name)
    }
}

struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CityView(city: model.cities[0])
            .environmentObject(ViewState(model: model))
    }
}
