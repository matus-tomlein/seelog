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
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
            let seenAreaUpdater = SeenAreaUpdater(context: context)
            let visitPeriodUpdater = VisitPeriodUpdater(context: context)

            allPhotos.enumerateObjects { asset, _, _ in
                if let location = asset.location {
                    if let photo = self.savePhoto(asset: asset, location: location) {
                        let photoInfo = PhotoInfo(photo: photo, geoDB: self.geoDatabase)

                        seenAreaUpdater.processNewPhoto(photoInfo: photoInfo)
                        visitPeriodUpdater.processNewPhoto(photoInfo: photoInfo)
                    }
                }
            }

            seenAreaUpdater.update()
            saveContext()
            print("Saved photos \(Date().timeIntervalSince(start))")
        }

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

    private func saveContext() {
        do {
            try self.context.save()
        } catch {
            print("Failed saving.")
            print(error)
        }
    }
    
}
