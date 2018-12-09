//
//  CountriesTableViewManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class CountriesTableViewManager: TableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool
    var purchasedHistory: Bool

    private var countries: [CountryInfo]?
    private var countryStates: [String: [String]]?

    init(year: Year, cumulative: Bool, purchasedHistory: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative
        self.purchasedHistory = purchasedHistory

        self.countries = year.countries(cumulative: cumulative, geoDB: geoDB)
        self.countryStates = year.countries(cumulative: cumulative)
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if year.isLocked(purchasedHistory: purchasedHistory) {
            return 0
        } else {
            return year.countries(cumulative: cumulative)?.count ?? 0
        }
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell

        if let countries = self.countries,
            let countryStates = self.countryStates {
            let country = countries[indexPath.row]

            cell.iconLabel.text = Helpers.flag(country: country.countryKey)
            cell.descriptionLabel.text = country.name

            if let states = countryStates[country.countryKey] {
                cell.subTextLabel.text = states.map({ geoDB.stateInfoFor(stateKey: $0)?.name ?? "" }).sorted().joined(separator: ", ")
            }
        }

        return cell
    }

    func numberOfSections() -> Int { return 1 }
    func titleForHeaderInSection(section: Int) -> String? { return nil }

}
