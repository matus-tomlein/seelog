//
//  ContinentsView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct ContinentsView: View {
    var body: some View {
        VStack {
            MapView()
                .edgesIgnoringSafeArea(.top)
                .frame(height: 300)

            VStack(alignment: .leading) {
                Text("Continents")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()

            Spacer()
        }
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        ContinentsView()
    }
}
