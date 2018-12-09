//
//  TimezonesTableViewManager.swift
//  seelog
//
//  Created by Matus Tomlein on 11/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class TimezonesTableViewManager: TableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool
    var timezones: [TimezoneInfo]
    var purchasedHistory: Bool

    init(year: Year, cumulative: Bool, purchasedHistory: Bool, tableView: UITableView, geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative
        self.purchasedHistory = purchasedHistory

        self.timezones = year.timezones(cumulative: cumulative, geoDB: geoDB) ?? []
        self.timezones = self.timezones.sorted(by: { $0.value < $1.value })
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        if year.isLocked(purchasedHistory: purchasedHistory) {
            return 0
        } else {
            return timezones.count
        }
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        let timezone = timezones[indexPath.row]
        cell.placeNameLabel.text = timezone.name
        cell.placeDescriptionLabel.text = timezone.places

        return cell
    }

    func numberOfSections() -> Int { return 1 }
    func titleForHeaderInSection(section: Int) -> String? { return nil }
    
}
