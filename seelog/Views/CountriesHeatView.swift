//
//  CountriesHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesHeatView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var countries: [Country] { get { return viewState.model.countriesForYear(selectedYear) } }

    var body: some View {
        PolygonView(
            shapes: viewState.model.continentInfos.map { continent in
                (
                    geometry: continent.geometry,
                    color: .gray
                )
                } + countries.map { country in
                    (
                        geometry: country.countryInfo.geometry110m,
                        color: .red
                    )
            },
            points: []
        ).frame(height: 370, alignment: Alignment.bottom)
    }
}

struct CountriesHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountriesHeatView().environmentObject(ViewState(model: model))
    }
}
