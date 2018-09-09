//
//  Photo.swift
//  seelog
//
//  Created by Matus Tomlein on 07/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    static func lastCreationDate(context: NSManagedObjectContext) -> Date? {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let photos = try context.fetch(request)
            if let photo = photos.first {
                return photo.creationDate
            }
        } catch _ {
            print("Failed to retrieve last photo")
        }
        
        return nil
    }
}
