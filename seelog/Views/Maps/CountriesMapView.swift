//
//  CountriesChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI
import MapKit
import GEOSwiftMapKit
import GEOSwift

struct CountriesMapView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    
    var year: Int?
    var countries: [Country] { return viewState.model.countriesForYear(year) }

    var body: some View {
        DrawablesMapView(drawables: countries, selectedYearState: selectedYearState)
    }
}

#Preview {
    CountriesMapView(selectedYearState: SelectedYearState())
        .environmentObject(ViewState(model: simulatedDomainModel()))
}
