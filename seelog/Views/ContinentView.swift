//
//  ContinentView.swift
//  seelog
//
//  Created by Matus Tomlein on 22/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentView: View {
    var continent: Continent
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        List {
            StayDurationBarChartView(destination: continent)
            TripsListView(destination: continent)
        }
        .navigationBarTitle(continent.continentInfo.name)
    }
}

struct ContinentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return ContinentView(continent: model.continents[0])
            .environmentObject(ViewState(model: model))
    }
}
