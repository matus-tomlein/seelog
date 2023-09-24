//
//  TrippableView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TrippableView: View {
    var trippable: Trippable
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    
    var body: some View {
        switch trippable {
        case let country as Country:
            CountryView(country: country, selectedYearState: selectedYearState)
                .environmentObject(self.viewState)
            
        case let region as Region:
            StateView(state: region, selectedYearState: selectedYearState)
                .environmentObject(self.viewState)
            
        case let city as City:
            CityView(city: city, selectedYearState: SelectedYearState())
                .environmentObject(self.viewState)
            
        case let timezone as Timezone:
            TimezoneView(timezone: timezone, selectedYearState: selectedYearState)
                .environmentObject(self.viewState)
            
        case let continent as Continent:
            ContinentView(continent: continent, selectedYearState: selectedYearState)
                .environmentObject(self.viewState)
            
        default:
            Text("Unknown")
        }
    }
}

