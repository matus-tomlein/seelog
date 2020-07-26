//
//  TimezoneListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezoneListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var timezone: Timezone

    var body: some View {
        NavigationLink(destination: TimezoneView(timezone: timezone)
            .environmentObject(self.viewState)
        ) {
            VStack(alignment: .leading, spacing: 5) {
                Text(timezone.timezoneInfo.name)
                    .font(.headline)
                Text("\(timezone.stayDurationForYear(self.selectedYear)) days")
            }
        }
    }
}

struct TimezoneListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return TimezoneListItemView(
            timezone: model.timezones[0]
        ).environmentObject(ViewState(model: model))
    }
}
