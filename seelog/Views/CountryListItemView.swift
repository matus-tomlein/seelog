//
//  CountryListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct CountryListItemView: View {
    var country: Country
    @ObservedObject var selectedYearState: SelectedYearState
    var selectedYear: Int? { get { return selectedYearState.year } }

    var body: some View {
        TextInfoView(info: country.info(year: selectedYear))
    }
}

struct CountryListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return CountryListItemView(
            country: model.countries.first(where: { $0.countryInfo.name == "Slovakia" })!,
            selectedYearState: SelectedYearState()
        )
    }
}
