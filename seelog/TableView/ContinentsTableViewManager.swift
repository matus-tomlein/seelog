//
//  ContinentsTableViewManager.swift
//  seelog
//
//  Created by Matus Tomlein on 11/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class ContinentsTableViewManager: TableViewManager {

    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool
    var continents: [String]

    init(year: Year, cumulative: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative

        self.continents = year.continents(cumulative: cumulative)?.sorted() ?? []
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return continents.count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        let continent = continents[indexPath.row]
        cell.placeNameLabel.text = continent
        cell.placeDescriptionLabel.text = ""

        return cell
    }

    func numberOfSections() -> Int { return 1 }
    func titleForHeaderInSection(section: Int) -> String? { return nil }
    
}
