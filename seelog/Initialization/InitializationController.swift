//
//  InitializationController.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import Photos
import CoreLocation
import CoreData

class InitializationController {
    var loadingViewState: LoadingViewState
    var persistentContainer: NSPersistentContainer
    
    init(loadingViewState: LoadingViewState, persistentContainer: NSPersistentContainer) {
        self.loadingViewState = loadingViewState
        self.persistentContainer = persistentContainer
    }
    
    func run() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            accessGranted()

        case .denied, .restricted:
            accessDenied()

        default:
            accessNotDetermined()
        }
    }

    private func accessGranted() {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            let databaseInitializer = DatabaseInitializer(context: context)
            databaseInitializer.start()
            
            if let model = self.createDomainModel(context: context) {
                DispatchQueue.main.async {
                    self.loadingViewState.viewState = ViewState(model: model)
                    self.loadingViewState.loading = false
                }
            }
        }
    }

    private func accessDenied() {
        loadingViewState.permissionGranted = false
    }

    private func accessNotDetermined() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.accessGranted()
            default:
                break
            }
        }
    }
    
    private func createDomainModel(context: NSManagedObjectContext) -> DomainModel? {
        do {
            let request = NSFetchRequest<VisitPeriod>(entityName: "VisitPeriod")
            let visitPeriods = try context.fetch(request)
            let trips = visitPeriods.enumerated().map { (i, visitPeriod) in
                Trip(
                    id: i,
                    since: visitPeriod.since ?? Date(),
                    until: visitPeriod.until ?? Date(),
                    visitedEntityType: visitPeriod.type,
                    visitedEntityKey: visitPeriod.visitedEntityKey ?? ""
                )
            }
            let geoDB = GeoDatabase()
            let model = DomainModel(trips: trips, seenGeometries: [], geoDatabase: geoDB)
            
            return model
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return nil
    }
}
