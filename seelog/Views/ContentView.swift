//
//  ContentView.swift
//  seelog
//
//  Created by Matus Tomlein on 28/12/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import SwiftUI

enum TableViewSetting {
    case trips
    case timeSpent
}

struct ContentView: View {
    @EnvironmentObject var loadingViewState: LoadingViewState

    @ViewBuilder
    var body: some View {
        if loadingViewState.loading {
            LoadingView()
        } else {
            MainView().environmentObject(loadingViewState.viewState!)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return ContentView()
            .environmentObject(ViewState(model: model))
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
            .environment(\.colorScheme, .dark)
    }
}
