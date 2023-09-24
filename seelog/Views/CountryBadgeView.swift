//
//  CountryBadgeView.swift
//  seelog
//
//  Created by Matus Tomlein on 07/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryBadgeView: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var selectedYearState: SelectedYearState
    var country: Country
    var year: Int? { get { return selectedYearState.year } }
    
    var foregroundColor: Color {
        return country.stayDurationStatusForYear(year).color ?? backgroundColor
    }
    var backgroundColor: Color {
        return country.explorationStatusForYear(year).color
    }

    var body: some View {
        NavigationLink(destination: CountryView(country: country, selectedYearState: selectedYearState)
            .environmentObject(self.viewState)
        ) {
            VStack {
                BadgeView(
                    geometryDescription: country.countryInfo.badgeGeometryDescription,
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor
                )
                Text(country.countryInfo.name)
                    .font(.headline)
                    .foregroundColor(Color(UIColor.label))
                Text("\(country.regionsForYear(self.year).count)/\(country.countryInfo.numberOfRegions) regions")
                    .foregroundColor(Color(UIColor.label))
                Text("\(country.stayDurationForYear(self.year)) days")
                    .foregroundColor(Color(UIColor.label))
            }.padding()
        }
    }
}

struct CountryBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return List {
            CountryBadgeView(
                country: model.countries.first(where: { $0.countryInfo.name == "Slovakia" })!
            ).environmentObject(ViewState(model: model))
            CountryBadgeView(
                country: model.countries.first(where: { $0.countryInfo.name == "Ukraine" })!
            ).environmentObject(ViewState(model: model))
            CountryBadgeView(
                country: model.countries.first(where: { $0.countryInfo.name == "Germany" })!
            ).environmentObject(ViewState(model: model))
        }
    }
}
