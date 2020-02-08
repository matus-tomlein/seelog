//
//  File.swift
//  
//
//  Created by Matus Tomlein on 01/01/2020.
//

import Foundation
import SwiftUI
import Combine

class InitializationState: ObservableObject {
    @Published var processingHeatmaps = false
    @Published var seenArea: Double = 0
    @Published var numberOfCountries: Int = 0
    @Published var numberOfStates: Int = 0
    @Published var numberOfCities: Int = 0
    @Published var numberOfContinents: Int = 0
    @Published var numberOfTimezones: Int = 0
}
