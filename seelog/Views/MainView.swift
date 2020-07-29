//
//  LogbookView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        NavigationView {
            LogbookView()
        }
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()

        return MainView()
            .environmentObject(ViewState(model: model))
    }
}
