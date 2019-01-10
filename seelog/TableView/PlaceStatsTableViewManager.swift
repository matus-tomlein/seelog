//
//  File.swift
//  Seelog
//
//  Created by Matus Tomlein on 06/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class PlaceStatsTableViewManager: TableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var allPlaceStats: [PlaceStats]
    private var filteredPlaceStats: [PlaceStats] = []
    var showing: Int = 0
    var reloadTableViewCallback: () -> ()
    var searchQuery = ""
    private let numRowsToLoadAtOnce = 50

    init(placeStatsManager: PlaceStatsManager, searchQuery: String, currentTab: SelectedTab, tableView: UITableView, reloadTableViewCallback: @escaping () -> (), geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.searchQuery = searchQuery
        self.allPlaceStats = placeStatsManager.placeStatsFor(currentTab: currentTab) ?? []
        self.reloadTableViewCallback = reloadTableViewCallback

        reload()
    }

    private var isLoadingMore = false
    func scrolledToBottom() {
        if !isLoadingMore {
            let newShowing = min(filteredPlaceStats.count, showing + numRowsToLoadAtOnce)

            if newShowing > showing {
                isLoadingMore = true
                showing = newShowing

                self.reloadTableViewCallback()
                self.isLoadingMore = false
            }
        }
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let placeStats = filteredPlaceStats[indexPath.row]

        let subtitle = placeStats.name(geoDB: geoDB)
        let icon = placeStats.icon(geoDB: geoDB)

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let numDays = numberFormatter.string(from: NSNumber(value: placeStats.numDays)) ?? String(placeStats.numDays)

        let subtext = "\(numDays) days over \(placeStats.years?.count ?? 0) years"

        if let icon = icon {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell
            cell.iconLabel.text = icon
            cell.subTextLabel.text = subtext
            cell.descriptionLabel.text = subtitle
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        cell.placeDescriptionLabel.text = subtext
        cell.placeNameLabel.text = subtitle
        return cell
    }

    func setSearchQuery(_ query: String) {
        searchQuery = query
        reload()
        reloadTableViewCallback()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return showing
    }

    func reload() {
        let query = searchQuery.lowercased()
        filteredPlaceStats = allPlaceStats.filter { query.isEmpty || $0.name(geoDB: geoDB).lowercased().contains(query) }
        showing = min(filteredPlaceStats.count, numRowsToLoadAtOnce)
    }

    func numberOfSections() -> Int { return 1 }
    func titleForHeaderInSection(section: Int) -> String? { return nil }
}
