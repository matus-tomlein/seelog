//
//  Timezone.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Timezone: Identifiable, Trippable {
    var id: Int32 { get { return timezoneInfo.timezoneId } }
    var timezoneInfo: TimezoneInfo

    var stayDurationByYear: [Int: Int]
    var trips: [Trip]
    var tripsByYear: [Int : [Trip]]
    var stayDuration: Int
    var years: [Int]

    func info(year: Int?) -> TextInfo {
        let link = ViewLink.timezone(self)
        if !visited(year: year) {
            return TextInfo(id: String(id), link: link, heading: timezoneInfo.name, enabled: false)
        }
        
        return TextInfo(
            id: String(id),
            link: link,
            heading: timezoneInfo.name,
            body: [
                "\(stayDurationForYear(year)) days"
            ]
        )
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
