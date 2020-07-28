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
    var statesCount: Int { return states.filter { $0.visited(year: year) }.count }
    @EnvironmentObject var viewState: ViewState
    var year: Int? { get { return viewState.selectedYear } }
    
    var body: some View {
        Section(header: Text("\(statesCount) regions")) {
            ForEach(states) { state in
                StateListItemView(region: state)
            }
        }
    }
}

struct StatesListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return List {
            StatesListView(states: model.states).environmentObject(ViewState(model: model))
        }
    }
}
