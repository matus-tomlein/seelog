//
//  SeenArea.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

extension SeenArea {
    var isTotal: Bool { get { return self.year <= 0 } }
    
    static func last(context: NSManagedObjectContext) -> SeenArea? {
        let request = NSFetchRequest<SeenArea>(entityName: "SeenArea")
        request.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "year", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            let last = try context.fetch(request).first
            if last?.isTotal ?? false { return nil }
            return last
        } catch _ {
            print("Failed to retrieve last seen area")
        }

        return nil
    }
    
    static func total(context: NSManagedObjectContext) -> SeenArea {
        do {
            let request = NSFetchRequest<SeenArea>(entityName: "SeenArea")
            request.predicate = NSPredicate(format: "year = %d", 0)
            request.fetchLimit = 1
            if let total = try context.fetch(request).first {
                return total
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        let total = SeenArea(context: context)
        total.year = 0
        total.geohashes = []
        return total
    }
}
