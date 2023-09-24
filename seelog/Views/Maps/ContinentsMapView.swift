//
//  ContinentsMapView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI
import MapKit

struct ContinentsMapView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    
    var year: Int?
    var continents: [Continent] { return viewState.model.continentsForYear(year) }
    
    var body: some View {
        DrawablesMapView(drawables: continents, selectedYearState: selectedYearState)
    }
}

#Preview {
    ContinentsMapView(selectedYearState: SelectedYearState())
        .environmentObject(ViewState(model: simulatedDomainModel()))
}
