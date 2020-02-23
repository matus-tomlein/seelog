//
//  YearStats.swift
//  seelog
//
//  Created by Matus Tomlein on 09/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

struct Year: Identifiable {
    var id: Int { get { return year } }
    var year: Int
    var cities: [City]
    var countries: [Country]
    var states: [State]
    var timezones: [Timezone]
    var continents: [Continent]
    var seenGeometry: SeenGeometry?
}
