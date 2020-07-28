//
//  StateListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StateListItemView: View {
    @EnvironmentObject var viewState: ViewState
    var region: Region
    var year: Int? { get { return viewState.selectedYear } }

    var body: some View {
        TextInfoView(info: region.info(year: year))
    }
}

struct StateListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return StateListItemView(
            region: model.states[0]
        ).environmentObject(ViewState(model: model))
    }
}
