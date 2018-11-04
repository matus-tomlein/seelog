//
//  HeatmapTableViewManager.swift
//  seelog
//
//  Created by Matus Tomlein on 04/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class HeatmapTableViewManager: TableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool
    var regions: [String: [String]]?

    var regionNames: [String]? {
        get {
            return regions?.keys.sorted()
        }
    }

    init(year: Year, cumulative: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative

        self.regions = year.regions(cumulative: cumulative, geoDB: geoDB)
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return 2 + (regions?.count ?? 0)
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        switch indexPath.row {
        case 0:
            if let timezones = year.timezoneNames(cumulative: cumulative, geoDB: geoDB) {
                cell.placeNameLabel.text = String(timezones.count) + " timezones"
                cell.placeDescriptionLabel.text = timezones.joined(separator: ", ")
            }

        case 1:
            if let continents = year.continents(cumulative: cumulative, geoDB: geoDB) {
                cell.placeNameLabel.text = String(continents.count) + " continents"
                cell.placeDescriptionLabel.text = continents.joined(separator: ", ")
            }

        default:
            if let region = regionNames?[indexPath.row - 2],
                let subregions = regions?[region] {
                cell.placeNameLabel.text = region
                cell.placeDescriptionLabel.text = subregions.sorted().joined(separator: ", ")
            }
        }

        return cell
    }
}
