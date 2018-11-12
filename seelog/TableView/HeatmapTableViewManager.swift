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

    init(year: Year, cumulative: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return 0
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell

        return cell
    }

    func numberOfSections() -> Int { return 1 }
    func titleForHeaderInSection(section: Int) -> String? { return nil }
    
}
