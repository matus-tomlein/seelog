//
//  CountryMapView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryMapView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { return selectedYearState.year }
    var country: Country
    
    var borderDrawables: [Drawable] {
        return [country]
    }
    var drawables: [Drawable] {
        return country.regionsForYear(year)
    }
    var cities: [City] {
        return country.citiesForYear(year: year)
    }

    var body: some View {
        DrawablesMapView(
            borderDrawables: borderDrawables,
            drawables: drawables,
            cities: cities,
            selectedYearState: selectedYearState
        )
    }
}

#Preview {
    let model = simulatedDomainModel()
    
    return CountryMapView(
        selectedYearState: SelectedYearState(),
        country: model.countries.first(where: { $0.countryInfo.name == "Hungary" })!
    )
        .environmentObject(ViewState(model: model))
}
