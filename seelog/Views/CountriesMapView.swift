//
//  MapView.swift
//  seelog
//
//  Created by Matus Tomlein on 28/12/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import SwiftUI
import MapKit

struct CountriesMapView: UIViewRepresentable {
    let countries: [Country]
    var mapView: MapView

    func makeUIView(context: Context) -> MapView {
        return mapView
    }

    func updateUIView(_ view: MapView, context: Context) {
        if countries.count > 0 {
            let mapManager = CountriesMapManager(countries: countries)
            view.getDelegate(mapManager: mapManager).load()
        }
    }
}

struct CountriesMapView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountriesMapView(
            countries: model.countriesForYear(nil),
            mapView: MapView(world: false)
        )
    }
}
