//
//  CountryListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var country: Country
    var selectedYear: Int? { get { return viewState.selectedYear } }

    var body: some View {
        NavigationLink(destination: CountryView(country: country)
            .environmentObject(self.viewState)
        ) {
            VStack(alignment: .leading, spacing: 5) {
                Text(country.countryInfo.name)
                    .font(.headline)
                Text("\(country.stayDurationForYear(self.selectedYear)) days")
            }
        }
    }
}

struct CountryListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountryListItemView(
            country: model.countries.first(where: { $0.countryInfo.name == "Slovakia" })!
        ).environmentObject(ViewState(model: model))
    }
}
