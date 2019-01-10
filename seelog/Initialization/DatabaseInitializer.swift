//
//  DatabaseInitializer.swift
//  seelog
//
//  Created by Matus Tomlein on 09/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData
import Photos

class DatabaseInitializer {
    var context: NSManagedObjectContext
    var geoDatabase = GeoDatabase()
    var initializationState: CurrentInitializationState
    
    init(initializationState: inout CurrentInitializationState, context: NSManagedObjectContext) {
        self.context = context
        self.initializationState = initializationState
    }

    func start() {
        var start = Date()
        let fetchOptions = PHFetchOptions()
        if let creationDate = Photo.lastCreationDate(context: self.context) {
            fetchOptions.predicate = NSPredicate(format: "creationDate > %@", creationDate as NSDate)
        }
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        print("Fetched photos \(Date().timeIntervalSince(start))")
        start = Date()
        if allPhotos.count > 0 {
            let yearStatsUpdater = YearStatsUpdater(initializationState: &initializationState,
                                                    context: context)
            let visitPeriodUpdater = VisitPeriodUpdater(context: context)

            allPhotos.enumerateObjects { asset, _, _ in
                if let location = asset.location {
                    if let photo = self.savePhoto(asset: asset, location: location) {
                        let photoInfo = PhotoInfo(photo: photo, geoDB: self.geoDatabase)

                        yearStatsUpdater.processNewPhoto(photoInfo: photoInfo)
                        visitPeriodUpdater.processNewPhoto(photoInfo: photoInfo)
                    }
                }
            }

            yearStatsUpdater.update()
            saveContext()
            print("Saved photos \(Date().timeIntervalSince(start))")
            start = Date()
        }

        initializationState.processingHeatmaps = true

        updateHeatmaps()
        print("Saved heatmaps \(Date().timeIntervalSince(start))")

        geoDatabase.clearCaches()
    }

    func savePhoto(asset: PHAsset, location: CLLocation) -> Photo? {
        let geohash = Geohash.encode(latitude: location.coordinate.latitude,
                                     longitude: location.coordinate.longitude,
                                     precision: .twentyKilometers)
        
        let newPhoto = Photo(context: self.context)
        newPhoto.creationDate = asset.creationDate
        if let date = asset.creationDate { newPhoto.year = Helpers.yearForDate(date) }
        newPhoto.latitude = location.coordinate.latitude
        newPhoto.localIdentifier = asset.localIdentifier
        newPhoto.longitude = location.coordinate.longitude
        newPhoto.geohash = geohash

        return newPhoto
    }

    private func updateHeatmaps() {
        do {
            let request = NSFetchRequest<Year>(entityName: "Year")
            request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: false)]
            let years = try context.fetch(request)
            var changed = false
            for year in years {
                if self.updateHeatmap(year: year) { changed = true }
            }
            if changed { self.saveContext() }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }

    private func updateHeatmap(year: Year) -> Bool {
        let heatmapUpdater = YearHeatmapUpdater(context: context)
        var changed = false
        if year.cumulativeProcessedHeatmapWKT == nil && year.year == Calendar.current.component(.year, from: Date()) {
            heatmapUpdater.update(year: year, cumulative: true)
            changed = true
        }
        if year.processedHeatmapWKT == nil {
            heatmapUpdater.update(year: year, cumulative: false)
            changed = true
        }
        return changed
    }

    private func saveContext() {
        do {
            try self.context.save()
        } catch {
            print("Failed saving.")
            print(error)
        }
    }
    
}
