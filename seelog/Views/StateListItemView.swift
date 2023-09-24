//
//  StateListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 01/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StateListItemView: View {
    var region: Region
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { get { return selectedYearState.year } }

    var body: some View {
        TrippableListItemView(
            trippable: region,
            selectedYearState: selectedYearState
        )
    }
}

struct StateListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return StateListItemView(
            region: model.states[0],
            selectedYearState: SelectedYearState()
        )
    }
}
