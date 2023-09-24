//
//  TimezonesMapView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezonesMapView: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { return selectedYearState.year }
    var timezones: [Timezone] { return viewState.model.timezonesForYear(year) }
    
    var body: some View {
        DrawablesMapView(drawables: timezones, selectedYearState: selectedYearState)
    }
}

#Preview {
    TimezonesMapView(selectedYearState: SelectedYearState())
        .environmentObject(ViewState(model: simulatedDomainModel()))
}
