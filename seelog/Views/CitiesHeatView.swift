//
//  CitiesHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CitiesHeatView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var cities: [City] { get { return viewState.model.citiesForYear(selectedYear) } }

    var body: some View {
        WorldView(
            background: (continents: viewState.model.continentInfos, countries: []),
            foreground: (continents: [], countries: [], regions: [], timezones: []),
            cities: cities.map { $0.cityInfo },
            detailed: false,
            opaque: true
        )
    }
}

struct CitiesHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CitiesHeatView().environmentObject(ViewState(model: model))
    }
}
