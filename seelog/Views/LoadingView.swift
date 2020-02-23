//
//  LoadingView.swift
//  seelog
//
//  Created by Matus Tomlein on 02/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack() {
            Spacer()
            CircleImage()

            VStack {
                Text("Loading...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
            }
            .padding()

            Spacer()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        return LoadingView()
            .colorScheme(.dark)
    }
}
