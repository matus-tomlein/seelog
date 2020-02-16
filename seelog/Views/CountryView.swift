//
//  CountryView.swift
//  seelog
//
//  Created by Matus Tomlein on 08/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryView: View {
    var country: Country
    var selectedYear: Int?
    
    var body: some View {
        List {
            BarChartView(
                yearStats: country.stayStatsByYear(),
                selectedYear: self.selectedYear
            )
            .listRowInsets(EdgeInsets())
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            Section(header: Text("\(country.stayDurationForYear(self.selectedYear)) days")) {
                ForEach(country.tripsForYear(self.selectedYear)) { trip in
                    Text(trip.formatDateInterval())
                }
            }
        }
        .navigationBarTitle(Text(country.countryInfo.name), displayMode: .inline)
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return CountryView(
            country: model.countries.first(where: { $0.countryInfo.name == "Denmark" })!,
            selectedYear: 2017
        )
    }
}
