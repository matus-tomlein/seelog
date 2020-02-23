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
            TripsListView(destination: city)
        }
        .navigationBarTitle(Text(city.cityInfo.name), displayMode: .inline)
    }
}

struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CityView(city: model.cities[0])
            .environmentObject(ViewState(model: model))
    }
}
