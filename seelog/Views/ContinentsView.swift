//
//  ContinentsView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentsView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(selectedYear) } }
    var yearStats: [(year: Int, count: Int)] { get { return viewState.model.continentYearCounts } }

    var body: some View {
        List {
            VStack(spacing: 0) {
                PolygonView(
                    shapes: viewState.model.continentInfos.map { continent in
                        (
                            geometry: continent.geometry,
                            color: .gray
                        )
                        } + continents.map { continent in
                            (
                                geometry: continent.continentInfo.geometry,
                                color: .red
                            )
                    },
                    points: []
                ).frame(height: 370, alignment: Alignment.bottom)

                BarChartView(showCounts: true, yearStats: yearStats)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .environmentObject(viewState)
            }.listRowInsets(EdgeInsets())

            Section(header: Text("\(continents.count) continents")) {
                ForEach(continents) { continent in
                    NavigationLink(destination: ContinentView(continent: continent)
                        .environmentObject(self.viewState)
                    ) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(continent.continentInfo.name)
                                .font(.headline)
                            Text("\(continent.stayDurationForYear(self.selectedYear)) days")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Continents")
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return ContinentsView().environmentObject(ViewState(model: model))
    }
}
