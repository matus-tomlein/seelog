//
//  StatesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct StatesListView: View {
    var states: [Region]
    var total: Int
    var statesCount: Int { return states.filter { $0.visited(year: year) }.count }
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { get { return selectedYearState.year } }
    
    var body: some View {
        Section(header: Text("\(statesCount) regions out of \(total)")) {
            ForEach(states) { state in
                StateListItemView(
                    region: state,
                    selectedYearState: self.selectedYearState
                )
            }
        }
    }
}

struct StatesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return List {
            StatesListView(
                states: model.states,
                total: model.states.count,
                selectedYearState: SelectedYearState()
            ).environmentObject(ViewState(model: model))
        }
    }
}
