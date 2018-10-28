//
//  VisitedCity.swift
//  seelog
//
//  Created by Matus Tomlein on 14/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

extension VisitedCity {
    static func all(context: NSManagedObjectContext) -> [VisitedCity]? {
        do {
            let request = NSFetchRequest<VisitedCity>(entityName: "VisitedCity")
            return try context.fetch(request)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return nil
    }
}
