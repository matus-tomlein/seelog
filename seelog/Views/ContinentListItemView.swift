//
//  ContinentListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var continent: Continent

    var body: some View {
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

struct ContinentListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return ContinentListItemView(
            continent: model.continents[0]
        ).environmentObject(ViewState(model: model))
    }
}
