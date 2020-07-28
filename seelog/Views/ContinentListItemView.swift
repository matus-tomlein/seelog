//
//  ContinentListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var selectedYear: Int? { get { return viewState.selectedYear } }
    var continent: Continent

    var body: some View {
        TextInfoView(info: continent.info(year: selectedYear))
    }
}

struct ContinentListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContinentListItemView(
            continent: model.continents[0]
        ).environmentObject(ViewState(model: model))
    }
}
