//
//  Timezone.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit
import GEOSwift

struct Timezone: Identifiable, Trippable, Drawable {
    var id: Int32 { return timezoneInfo.timezoneId }
    var _id: String { return "\(id)" }
    var name: String { return timezoneInfo.name }
    var nameWithFlag: String { return name }
    var timezoneInfo: TimezoneInfo
    var coordinateRegion: MKCoordinateRegion { return timezoneInfo.geometryDescription.coordinateRegion }

    var stayDurationByYear: [Int: Int]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]

    func info(year: Int?) -> TextInfo {
        let link = ViewLink.timezone(self)
        if !visited(year: year) {
            return TextInfo(id: String(id), link: link, heading: timezoneInfo.name, status: .notVisited, enabled: false)
        }
        
        return TextInfo(
            id: String(id),
            link: link,
            heading: timezoneInfo.name,
            status: status(year: year),
            body: [
                stayDurationInfo(year: year)
            ]
        )
    }
    
    func explored(year: Int?) -> Bool? {
        return nil
    }
    
    func polygons(zoomType: ZoomType) -> [Polygon] {
        timezoneInfo.geometryDescription.polygons
    }
    
    func intersects(mapRegion: MKCoordinateRegion) -> Bool {
        return true
    }
}

extension Timezone {
    init(timezoneInfo: TimezoneInfo, trips: [Trip]) {
        self.timezoneInfo = timezoneInfo
        self.trips = trips

        let tripsInfo = Trip.extractTripsInfo(trips: trips)
        self.tripsByYear = tripsInfo.tripsByYear
        self.stayDurationByYear = tripsInfo.stayDurationByYear
        self.stayDuration = tripsInfo.stayDuration
        self.years = tripsInfo.years
    }
}
