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
    var purchasedHistory: Bool

    private var majorCities: [CityInfo]?
    private var otherCities: [CityInfo]?

    init(year: Year, cumulative: Bool, purchasedHistory: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative
        self.purchasedHistory = purchasedHistory

        let cities = year.cities(cumulative: cumulative)?.map({ geoDB.cityInfoFor(cityKey: $0) }).filter({ $0 != nil }).map({ $0! }).sorted { $0.name < $1.name }
        majorCities = cities?.filter({ $0.worldCity || $0.megaCity })
        otherCities = cities?.filter({ !$0.worldCity && !$0.megaCity })
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        if year.isLocked(purchasedHistory: purchasedHistory) {
            return 0
        }
        let majorCitiesOnly = section == 0
        return (majorCitiesOnly ? self.majorCities : self.otherCities)?.count ?? 0
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell
        let majorCitiesOnly = indexPath.section == 0

        if let cities = (majorCitiesOnly ? self.majorCities : self.otherCities) {
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

    func numberOfSections() -> Int {
        return 2
    }

    func titleForHeaderInSection(section: Int) -> String? {
        let isLocked = year.isLocked(purchasedHistory: purchasedHistory)
        switch section {
        case 0:
            return isLocked ? "Major Cities" : "\(self.majorCities?.count ?? 0) Major Cities"
        default:
            return isLocked ? "Cities and Towns" : "\(self.otherCities?.count ?? 0) Cities and Towns"
        }
    }

}
