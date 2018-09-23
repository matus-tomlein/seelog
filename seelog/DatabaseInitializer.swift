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
        var countriesForYears = [Int: [String]]()
        let calendar = Calendar.current

        let fetchOptions = PHFetchOptions()
        if let creationDate = Photo.lastCreationDate(context: self.context) {
            fetchOptions.predicate = NSPredicate(format: "creationDate > %@", creationDate as NSDate)
        }
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        allPhotos.enumerateObjects { asset, _, _ in
            if let location = asset.location {
                if let photo = self.savePhoto(asset: asset, location: location),
                    let date = photo.creationDate,
                    let countryKey = photo.countryKey {
                    let year = calendar.component(.year, from: date)
                    if let countries = countriesForYears[year] {
                        if !countries.contains(countryKey) {
                            countriesForYears[year] = countries + [countryKey]
                        }
                    } else {
                        countriesForYears[year] = [countryKey]
                    }
                }
            }
        }

        for year in countriesForYears.keys {
            let countries = countriesForYears[year]!

            let request = NSFetchRequest<Year>(entityName: "Year")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "year == %@", NSNumber(value: year))

            do {
                let years = try context.fetch(request)
                if let model = years.first {
                    var newCountries: [String] = []
                    for country in countries {
                        if !(model.countries?.contains(country) ?? false) {
                            newCountries.append(country)
                        }
                    }
                    if newCountries.count > 0 {
                        model.countries = (model.countries ?? []) + newCountries
                        try context.save()
                    }
                } else {
                    let model = Year(context: self.context)
                    model.year = Int32(year)
                    model.countries = countries
                    try context.save()
                }
            } catch {
                print("Failed to fetch years.")
            }
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

        do {
            try context.save()
            return newPhoto
        } catch {
            print("Failed saving")
        }

        return nil
    }
    
    
}
