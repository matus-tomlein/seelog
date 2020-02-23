//
//  CitiesView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CitiesView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var cities: [City] { get { return viewState.model.citiesForYear(selectedYear) } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.cityYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
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

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(viewState)
            }.listRowInsets(EdgeInsets())

            CitiesListView(cities: cities)
        }
        .navigationBarTitle("Cities")
    }
}

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CitiesView().environmentObject(ViewState(model: model))
    }
}
