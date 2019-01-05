//
//  VisitPeriodsTableViewManager.swift
//  Seelog
//
//  Created by Matus Tomlein on 22/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class VisitPeriodsTableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool
    var visitPeriods: [VisitPeriod]
    var purchasedHistory: Bool
    var showing: Int = 0
    var reloadTableViewCallback: () -> ()
    var searchQuery = ""
    private let numRowsToLoadAtOnce = 50

    private var sections: [String] = []
    private var visitPeriodsBySections: [[VisitPeriod]] = []

    init(visitPeriodManager: VisitPeriodManager, year: Year, cumulative: Bool, searchQuery: String, purchasedHistory: Bool, currentTab: SelectedTab, tableView: UITableView, reloadTableViewCallback: @escaping () -> (), geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative
        self.searchQuery = searchQuery
        self.purchasedHistory = purchasedHistory
        self.visitPeriods = visitPeriodManager.periodsFor(year: year, cumulative: cumulative, currentTab: currentTab, purchasedHistory: purchasedHistory) ?? []
        self.reloadTableViewCallback = reloadTableViewCallback

        reload()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return visitPeriodsBySections[section].count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let period = visitPeriodsBySections[indexPath.section][indexPath.row]
        var title = ""

        if let since = period.since,
            let until = period.until {
            title = Helpers.formatDateRange(since: since, until: until)
        }

        let subtitle = period.name(geoDB: geoDB)
        let icon = period.icon(geoDB: geoDB)

        if let icon = icon {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell
            cell.iconLabel.text = icon
            cell.subTextLabel.text = title
            cell.descriptionLabel.text = subtitle
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        cell.placeDescriptionLabel.text = title
        cell.placeNameLabel.text = subtitle
        return cell
    }

    private var isLoadingMore = false
    func scrolledToBottom() {
        if !isLoadingMore {
            let newShowing = min(visitPeriods.count, showing + numRowsToLoadAtOnce)

            if newShowing > showing {
                isLoadingMore = true
                showing = newShowing
                reload()

                self.reloadTableViewCallback()
                self.isLoadingMore = false
            }
        }
    }

    func numberOfSections() -> Int { return sections.count }
    func titleForHeaderInSection(section: Int) -> String? { return sections[section] }

    func reload() {
        self.sections = []
        self.visitPeriodsBySections = []

        var lastSection = ""
        var lastSectionPeriods: [VisitPeriod] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        let query = searchQuery.lowercased()
        let visitPeriods = self.visitPeriods.filter { query.isEmpty || $0.name(geoDB: geoDB).lowercased().contains(query) }

        self.showing = min(visitPeriods.count, numRowsToLoadAtOnce)
        for i in 0..<showing {
            let period = visitPeriods[i]

            guard let since = period.since else { continue }

            let sectionName = dateFormatter.string(from: since)

            if sectionName == lastSection {
                lastSectionPeriods.append(period)
            } else {
                if lastSectionPeriods.count > 0 {
                    sections.append(lastSection)
                    visitPeriodsBySections.append(lastSectionPeriods)
                }
                lastSection = sectionName
                lastSectionPeriods = [period]
            }
        }

        if lastSectionPeriods.count > 0 {
            sections.append(lastSection)
            visitPeriodsBySections.append(lastSectionPeriods)
        }
    }

}
