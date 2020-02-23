//
//  StateView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StateView: View {
    var state: State
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        List {
            StayDurationBarChartView(destination: state)
            TripsListView(destination: state)
        }
        .navigationBarTitle(Text(state.stateInfo.name), displayMode: .inline)
    }
}

struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return StateView(state: model.states[0])
            .environmentObject(ViewState(model: model))
    }
}
