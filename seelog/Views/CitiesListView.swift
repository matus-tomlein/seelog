//
//  CitiesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CitiesListView: View {
    @EnvironmentObject var viewState: ViewState
    var cities: [City]
    var citiesCount: Int { return cities.filter { $0.visited(year: selectedYear) }.count }
    var selectedYear: Int? { get { return viewState.selectedYear } }

    var body: some View {
        Section(header: Text("\(citiesCount) cities")) {
            ForEach(cities) { city in
                CityListItemView(city: city)
            }
        }
    }
}

struct CitiesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return List {
            CitiesListView(cities: model.cities).environmentObject(ViewState(model: model))
        }
    }
}
