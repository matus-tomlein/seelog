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
    @EnvironmentObject var initializationState: CurrentInitializationState

    var body: some View {
        TabView {
            LoadingView().tabItem {
                Image(systemName: "phone.fill")
                Text("Places")
            }
            
            CountriesView(countries: [], yearStats: []).tabItem {
                Image(systemName: "phone.fill")
                Text("Countries")
            }
            
            CitiesView().tabItem {
                Image(systemName: "phone.fill")
                Text("Cities")
            }
            
            ContinentsView().tabItem {
                Image(systemName: "phone.fill")
                Text("Continents")
            }
            
            TimezonesView().tabItem {
                Image(systemName: "phone.fill")
                Text("Timezones")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .environmentObject(CurrentInitializationState())
    }
}
