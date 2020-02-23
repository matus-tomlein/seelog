//
//  TimezoneView.swift
//  seelog
//
//  Created by Matus Tomlein on 22/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezoneView: View {
    var timezone: Timezone
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        List {
            StayDurationBarChartView(destination: timezone)
            TripsListView(destination: timezone)
        }
        .navigationBarTitle(Text(timezone.timezoneInfo.name), displayMode: .inline)
    }
}

struct TimezoneView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return TimezoneView(
            timezone: model.timezones[0]
        ).environmentObject(ViewState(model: model))
    }
}
