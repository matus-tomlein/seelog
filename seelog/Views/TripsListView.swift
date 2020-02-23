//
//  TripsListView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TripsListView: View {
    var destination: Trippable
    @EnvironmentObject var viewState: ViewState
    var trips: [Trip] { get { return destination.tripsForYear(viewState.selectedYear) } }

    var body: some View {
        Section(header: Text("\(trips.count) trips")) {
            ForEach(trips) { trip in
                Text(trip.formatDateInterval())
            }
        }
    }
}

struct TripsListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return List {
            TripsListView(destination: model.countries[0])
        }
    }
}
