//
//  ReportBarChartSelection.swift
//  seelog
//
//  Created by Matus Tomlein on 23/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData

class ReportBarChartSelection {
    var reportViewController: ReportViewController
    var visitStats = AggregatedVisitStats()

    var aggregates: [Aggregate]? {
        get { return visitStats.aggregates }
    }

    var _currentSelection: String?
    var currentSelection: String? {
        set {
            _currentSelection = newValue
        }
        get {
            return _currentSelection ?? visitStats.aggregates?.last?.name
        }
    }
    var countries: [String]? {
        get {
            return visitStats.allCountries()
        }
    }
    var currentCountries: [String]? {
        get {
            if let selection = self.currentSelection {
                return visitStats.countriesForSelection(name: selection)
            }
            return countries
        }
    }
    var flaggedItems: [String]? {
        get { return currentCountries?.map { Helpers.flag(country: $0) } }
    }
    var currentTab: SelectedTab { get { return reportViewController.currentTab } }
    var aggregateChart: Bool { get { return reportViewController.aggregateChart } }

    var currentAggregate: Aggregate? {
        get {
            if let selection = currentSelection {
                if let filtered = visitStats.aggregates?.filter({ $0.name == selection }) {
                    if filtered.count > 0 {
                        return filtered[0]
                    }
                }
            }
            return nil
        }
    }

    init(reportViewController: ReportViewController) {
        self.reportViewController = reportViewController
    }

    func loadItems(context: NSManagedObjectContext) {
        visitStats.loadItems(granularity: reportViewController.granularity,
                             context: context)
    }

    func clear() {
        currentSelection = nil
    }

    func reload() {
        reportViewController.reloadAllAndScrollChart(false)
    }

}
