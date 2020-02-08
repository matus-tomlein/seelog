//
//  LoadingView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var initializationState: CurrentInitializationState
    
    var body: some View {
        VStack() {
            Spacer()
            CircleImage()

            VStack {
                Text("Loading")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                HStack {
                    Text("\(Int64(self.initializationState.seenArea)) km²")
                        .font(.title)
                    Spacer()
                    Text("\(self.initializationState.numberOfCountries) countries")
                        .font(.title)
                }
                HStack {
                    Text("\(self.initializationState.numberOfStates) regions")
                        .font(.title)
                    Spacer()
                    Text("\(self.initializationState.numberOfCities) cities")
                        .font(.title)
                }
                HStack {
                    Text("\(self.initializationState.numberOfContinents) continents")
                        .font(.title)
                    Spacer()
                    Text("\(self.initializationState.numberOfTimezones) timezones")
                        .font(.title)
                }
            }
            .padding()

            Spacer()
            Spacer()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(CurrentInitializationState())
    }
}
