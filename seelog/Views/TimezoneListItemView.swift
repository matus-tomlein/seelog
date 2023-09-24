//
//  TimezoneListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezoneListItemView: View {
    var timezone: Timezone
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }

    var body: some View {
        TrippableListItemView(trippable: timezone, selectedYearState: selectedYearState)
    }
}

struct TimezoneListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return TimezoneListItemView(
            timezone: model.timezones[0],
            selectedYearState: SelectedYearState()
        ).environmentObject(ViewState(model: model))
    }
}
