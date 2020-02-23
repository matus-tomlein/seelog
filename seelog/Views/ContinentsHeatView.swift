//
//  ContinentsHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentsHeatView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var continents: [Continent] { get { return viewState.model.continentsForYear(selectedYear) } }

    var body: some View {
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
    }
}

struct ContinentsHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return ContinentsHeatView().environmentObject(ViewState(model: model))
    }
}
