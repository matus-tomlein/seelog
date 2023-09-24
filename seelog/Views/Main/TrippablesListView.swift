//
//  TrippablesListView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TrippableListView<ItemType: Trippable & Identifiable>: View {
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { get { return selectedYearState.year } }
    var trippables: [ItemType]
    var sorted: [ItemType] {
        return trippables
            .sorted(by: { $0.stayDurationForYear(year) > $1.stayDurationForYear(year) })
    }
    
    var body: some View {
        let maxStayDuration = trippables.map { $0.stayDurationForYear(year) }.max() ?? 0
        
        ForEach(sorted) { trippable in
            TrippableListItemView(
                trippable: trippable,
                selectedYearState: selectedYearState,
                maxStayDuration: trippables.count > 1 ? maxStayDuration : nil
            )
            .environmentObject(self.viewState)
        }
    }
}

