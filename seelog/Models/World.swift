//
//  World.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct World: Identifiable, Trippable {
    var id: String { get { return "world" } }
    var name: String { return "World" }
    var nameWithFlag: String { return name }

    var stayDurationByYear: [Int: Int]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]
    
    func explored(year: Int?) -> Bool? {
        return nil
    }
    
    func info(year: Int?) -> TextInfo {
        TextInfo(id: "world", link: .none, heading: "World", status: .explored)
    }
}

extension World {
    init(trips: [Trip]) {
        self.trips = trips

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
}
