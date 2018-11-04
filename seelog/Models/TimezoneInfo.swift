//
//  TimezoneInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 03/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

struct TimezoneInfo {
    var timezoneId: Int32
    var name: String
    var places: String

    init(timezoneId: Int32, name: String, places: String) {
        self.timezoneId = timezoneId
        self.name = name
        self.places = places
    }
}
