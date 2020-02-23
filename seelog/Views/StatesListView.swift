//
//  StatesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StatesListView: View {
    var states: [Region]
    @EnvironmentObject var viewState: ViewState
    var year: Int? { get { return viewState.selectedYear } }
    
    var body: some View {
        Section(header: Text("\(states.count) regions")) {
            ForEach(states) { state in
                NavigationLink(destination: StateView(state: state)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(state.stateInfo.name)
                            .font(.headline)
                        Text("\(state.stayDurationForYear(self.year)) days")
                    }
                }
            }
        }
    }
}

struct StatesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return List {
            StatesListView(states: model.states).environmentObject(ViewState(model: model))
        }
    }
}
