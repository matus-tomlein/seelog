//
//  TimezonesView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TimezonesView: View {
    var body: some View {
        VStack {
            MapView()
                .edgesIgnoringSafeArea(.top)
                .frame(height: 300)

            VStack(alignment: .leading) {
                Text("Timezones")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()

            Spacer()
        }
    }
}

struct TimezonesView_Previews: PreviewProvider {
    static var previews: some View {
        TimezonesView()
    }
}
