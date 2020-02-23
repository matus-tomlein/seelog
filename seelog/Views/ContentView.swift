//
//  ContentView.swift
//  seelog
//
//  Created by Matus Tomlein on 28/12/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import SwiftUI

enum SelectedTab {
    case places
    case countries
    case states
    case cities
    case timezones
    case continents
}

enum TableViewSetting {
    case trips
    case timeSpent
}

struct ContentView: View {
    @EnvironmentObject var viewState: ViewState

    @ViewBuilder
    var body: some View {
        if viewState.loading {
            LoadingView()
        } else {
            LogbookView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return ContentView()
            .environmentObject(ViewState(model: model))
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
            .environment(\.colorScheme, .dark)
    }
}
