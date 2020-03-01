//
//  TimezoneHeatView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezoneHeatView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var timezones: [Timezone] { get { return viewState.model.timezonesForYear(selectedYear) } }

    var body: some View {
        WorldView(
            background: (continents: viewState.model.continentInfos, countries: []),
            foreground: (continents: [], countries: [], regions: [], timezones: timezones.map { $0.timezoneInfo }),
            cities: [],
            detailed: false,
            opaque: true
        )
    }
}

struct TimezoneHeatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())

        return TimezoneHeatView().environmentObject(ViewState(model: model))
    }
}
