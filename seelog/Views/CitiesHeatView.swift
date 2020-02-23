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
        PolygonView(
            shapes: viewState.model.continentInfos.map { continent in
                (
                    geometry: continent.geometry,
                    color: .gray
                )
            },
            points: cities.map { city in
                (
                    lat: city.cityInfo.latitude,
                    lng: city.cityInfo.longitude,
                    color: .red
                )
            }
        ).frame(height: 370, alignment: Alignment.bottom)
    }
}

struct CitiesHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CitiesHeatView().environmentObject(ViewState(model: model))
    }
}
