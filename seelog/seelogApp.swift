//
//  seelogApp.swift
//  seelog
//
//  Created by Matus Tomlein on 07/10/2023.
//

import SwiftUI
import CoreData

@main
struct seelogApp: App {
    
    init() {
        let initializer = InitializationController(loadingViewState: loadingViewState, persistentContainer: persistentContainer)
        initializer.run()
    }
    
    let loadingViewState = LoadingViewState()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "seelog")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loadingViewState)
        }
    }
}
