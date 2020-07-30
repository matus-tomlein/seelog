//
//  LogbookLinkView.swift
//  seelog
//
//  Created by Matus Tomlein on 30/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LogbookLinkView: View {
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        NavigationLink(destination: LogbookView().environmentObject(self.viewState)) {
            Image(systemName: "house")
        }
    }
}

struct LogbookLinkView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookLinkView()
    }
}
