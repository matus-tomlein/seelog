//
//  CountriesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountriesListView: View {
    var countries: [Country]
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        Section(header: Text("\(countries.count) countries")) {
            ForEach(countries) { country in
                CountryListItemView(country: country)
            }
        }
    }
}

struct CountriesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return List {
            CountriesListView(countries: model.countries)
                .environmentObject(ViewState(model: model))
        }
    }
}
