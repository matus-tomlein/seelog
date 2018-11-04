//
//  CitiesTableViewManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class CitiesTableViewManager: TableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool

    private var cities: [CityInfo]?

    init(year: Year, cumulative: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative

        self.cities = year.cities(cumulative: cumulative)?.map({ geoDB.cityInfoFor(cityKey: $0) }).filter({ $0 != nil }).map({ $0! }).sorted { $0.name < $1.name }
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return cities?.count ?? 0
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell

        if let cities = self.cities {
            let city = cities[indexPath.row]

            cell.iconLabel.text = Helpers.flag(country: city.countryKey)
            cell.descriptionLabel.text = city.name
            if city.populationMin == city.populationMax {
                cell.subTextLabel.text = "Population: \(city.populationMin)"
            } else {
                cell.subTextLabel.text = "Population: \(city.populationMin) – \(city.populationMax)"
            }
        }

        return cell
    }
}
