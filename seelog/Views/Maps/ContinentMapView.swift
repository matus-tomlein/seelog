//
//  ContinentMapView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentMapView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int?
    var continent: Continent
    
    var borderDrawables: [Drawable] {
        return [continent]
    }
    var drawables: [Drawable] {
        return continent.countriesForYear(year)
    }

    var body: some View {
        DrawablesMapView(
            borderDrawables: borderDrawables,
            drawables: drawables,
            selectedYearState: selectedYearState
        )
    }
}

#Preview {
    let model = simulatedDomainModel()
    
    return ContinentMapView(
        selectedYearState: SelectedYearState(),
        continent: model.continents.first!
    )
        .environmentObject(ViewState(model: model))
}
