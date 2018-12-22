//
//  VisitPeriodsTableViewManager.swift
//  Seelog
//
//  Created by Matus Tomlein on 22/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class VisitPeriodsTableViewManager: TableViewManager {
    var geoDB: GeoDatabase
    var tableView: UITableView
    var year: Year
    var cumulative: Bool
    var visitPeriods: [VisitPeriod]
    var purchasedHistory: Bool
    var showing: Int = 0
    var reloadTableViewCallback: () -> ()
    private let numRowsToLoadAtOnce = 50

    private var sections: [String] = []
    private var visitPeriodsBySections: [[VisitPeriod]] = []

    init(visitPeriodManager: VisitPeriodManager, year: Year, cumulative: Bool, purchasedHistory: Bool, currentTab: SelectedTab, tableView: UITableView, reloadTableViewCallback: @escaping () -> (), geoDB: GeoDatabase) {
        self.geoDB = geoDB
        self.tableView = tableView
        self.year = year
        self.cumulative = cumulative
        self.purchasedHistory = purchasedHistory
        self.visitPeriods = visitPeriodManager.periodsFor(year: year, cumulative: cumulative, currentTab: currentTab, purchasedHistory: purchasedHistory) ?? []
        self.reloadTableViewCallback = reloadTableViewCallback
        self.showing = min(self.visitPeriods.count, numRowsToLoadAtOnce)

        reloadSections()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return visitPeriodsBySections[section].count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let period = visitPeriodsBySections[indexPath.section][indexPath.row]
        var title = ""
        var subtitle = ""
        var icon: String?

        if let since = period.since,
            let until = period.until {
            title = Helpers.formatDateRange(since: since, until: until)
        }

        if let countryInfo = period.countryInfo(geoDB: geoDB) {
            subtitle = countryInfo.name
            icon = Helpers.flag(country: countryInfo.countryKey)
        } else if let stateInfo = period.stateInfo(geoDB: geoDB) {
            subtitle = stateInfo.name
            icon = Helpers.flag(country: stateInfo.countryKey)
        } else if let cityInfo = period.cityInfo(geoDB: geoDB) {
            subtitle = cityInfo.name
            icon = Helpers.flag(country: cityInfo.countryKey)
        } else if let timezoneInfo = period.timezoneInfo(geoDB: geoDB) {
            subtitle = timezoneInfo.name
        } else if let continentInfo = period.continentInfo(geoDB: geoDB) {
            subtitle = continentInfo.name
        }

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
                reloadSections()

                self.reloadTableViewCallback()
                self.isLoadingMore = false
            }
        }
    }

    func numberOfSections() -> Int { return sections.count }
    func titleForHeaderInSection(section: Int) -> String? { return sections[section] }

    private func reloadSections() {
        self.sections = []
        self.visitPeriodsBySections = []

        var lastSection = ""
        var lastSectionPeriods: [VisitPeriod] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

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
