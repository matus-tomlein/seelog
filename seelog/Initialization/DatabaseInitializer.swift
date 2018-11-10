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
        let yearStatsUpdater = YearStatsUpdater(context: context)
        let visitedPlacesUpdater = VisitedPlacesStats()

        let fetchOptions = PHFetchOptions()
        if let creationDate = Photo.lastCreationDate(context: self.context) {
            fetchOptions.predicate = NSPredicate(format: "creationDate > %@", creationDate as NSDate)
        }
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        allPhotos.enumerateObjects { asset, _, _ in
            if let location = asset.location {
                if let photo = self.savePhoto(asset: asset, location: location) {
                    yearStatsUpdater.processNewPhoto(photo: photo)
                    visitedPlacesUpdater.processNewPhoto(photo: photo)
                }
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed saving")
        }

        yearStatsUpdater.update()
        visitedPlacesUpdater.update(context: context)

        do {
            try context.save()
        } catch {
            print("Failed saving.")
        }
    }

    func savePhoto(asset: PHAsset, location: CLLocation) -> Photo? {
        let geohash = Geohash.encode(latitude: location.coordinate.latitude,
                                     longitude: location.coordinate.longitude,
                                     precision: .twentyKilometers)
        
        let newPhoto = Photo(context: self.context)
        newPhoto.altitude = location.altitude
        newPhoto.creationDate = asset.creationDate
        newPhoto.latitude = location.coordinate.latitude
        newPhoto.localIdentifier = asset.localIdentifier
        newPhoto.longitude = location.coordinate.longitude
        newPhoto.geohash = geohash

        newPhoto.countryKey = self.geoDatabase.countryKeyFor(geohash: geohash)
        newPhoto.stateKey = self.geoDatabase.stateKeyFor(geohash: geohash)
        newPhoto.cityKeys = self.geoDatabase.cityKeysFor(geohash: geohash)
        newPhoto.timezone = self.geoDatabase.timezoneFor(geohash: geohash) ?? 0

        return newPhoto
    }
    
    
}
