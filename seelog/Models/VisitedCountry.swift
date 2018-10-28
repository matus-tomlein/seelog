//
//  VisitedCountry.swift
//  seelog
//
//  Created by Matus Tomlein on 01/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

extension VisitedCountry {
    static func all(context: NSManagedObjectContext) -> [VisitedCountry]? {
        do {
            let request = NSFetchRequest<VisitedCountry>(entityName: "VisitedCountry")
            return try context.fetch(request)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return nil
    }
}
