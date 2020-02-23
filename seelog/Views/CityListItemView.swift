//
//  CityListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CityListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var city: City
    
    var body: some View {
        NavigationLink(destination: CityView(city: city).environmentObject(self.viewState)) {
            VStack(alignment: .leading, spacing: 5) {
                Text(city.cityInfo.name)
                    .font(.headline)
                Text("\(city.stayDurationForYear(self.selectedYear)) days")
            }
        }
    }
}

struct CityListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())

        return CityListItemView(
            city: model.cities[0]
        ).environmentObject(ViewState(model: model))
    }
}
