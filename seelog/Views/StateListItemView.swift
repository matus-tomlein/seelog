//
//  StateListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StateListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var region: Region
    var year: Int? { get { return viewState.selectedYear } }

    var body: some View {
        NavigationLink(destination: StateView(state: region)) {
            VStack(alignment: .leading, spacing: 5) {
                Text(region.stateInfo.name)
                    .font(.headline)
                Text("\(region.stayDurationForYear(self.year)) days")
            }
        }
    }
}

struct StateListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return StateListItemView(
            region: model.states[0]
        ).environmentObject(ViewState(model: model))
    }
}
