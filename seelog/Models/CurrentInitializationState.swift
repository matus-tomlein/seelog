//
//  File.swift
//  
//
//  Created by Matus Tomlein on 01/01/2020.
//

import Foundation
import SwiftUI
import Combine
import CoreData

final class CurrentInitializationState: ObservableObject {
    @Published var processingHeatmaps = false
    @Published var seenArea: Double = 0
    @Published var numberOfCountries: Int = 0
    @Published var numberOfStates: Int = 0
    @Published var numberOfCities: Int = 0
    @Published var numberOfContinents: Int = 0
    @Published var numberOfTimezones: Int = 0
    
    var visitPeriodManager: VisitPeriodManager
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.visitPeriodManager = VisitPeriodManager(context: context)
    }
}
