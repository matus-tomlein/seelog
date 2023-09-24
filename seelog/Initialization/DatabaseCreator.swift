//
//  DatabaseCreator.swift
//  Seelog
//
//  Created by Matus Tomlein on 03/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class DatabaseCreator {
    static let currentDatabaseVersion: Double = 1.4

    static func create(container: NSPersistentContainer) {
        let databaseVersionKey = "app.seelog.databaseversion"
        let dbVersion = UserDefaults.standard.double(forKey: databaseVersionKey)

        if dbVersion >= currentDatabaseVersion { return }
        UserDefaults.standard.set(currentDatabaseVersion, forKey: databaseVersionKey)

        if let url = container.persistentStoreDescriptions.first?.url {
            let coordinator = container.persistentStoreCoordinator

            do {
                try coordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
