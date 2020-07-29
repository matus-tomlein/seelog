//
//  TextInfo.swift
//  seelog
//
//  Created by Matus Tomlein on 27/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

enum ViewLink {
    case none
    case countries
    case country(Country)
    case cities
    case city(City)
    case regions
    case region(Region)
    case continents
    case continent(Continent)
    case timezones
    case timezone(Timezone)
}

struct TextInfo: Identifiable {
    var id: String
    var link: ViewLink
    var heading: String
    var status: Status
    var body: [String] = []
    var enabled: Bool = true
}
