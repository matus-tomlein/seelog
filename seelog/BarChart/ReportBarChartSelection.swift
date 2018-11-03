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
    var currentAggregate: Aggregate? {
        get {
            if let selection = currentSelection { return visitStats.aggregateWithName(selection) }
            return nil
        }
    }

    var _currentSelection: String?
    var currentSelection: String? {
        set {
            _currentSelection = newValue
        }
        get { return _currentSelection ?? visitStats.aggregates?.last?.name }
    }
    var currentCountries: [String]? {
        get { return currentAggregate?.countries(cumulative: aggregateChart)?.keys.sorted() }
    }
    var currentCountriesAndStates: [String: [String]]? {
        get { return currentAggregate?.countries(cumulative: aggregateChart) }
    }
    var currentCities: [CityInfo]? {
        get {
            let cities = currentAggregate?.cities(cumulative: aggregateChart)
            let cityInfos = cities?.map({ reportViewController.geoDB.cityInfoFor(cityKey: $0) })
            return cityInfos?.filter({ $0 != nil }).map({ $0! }).sorted(by: { $0.name < $1.name })
        }
    }
    var currentTab: SelectedTab { get { return reportViewController.currentTab } }
    var aggregateChart: Bool { get { return reportViewController.aggregateChart } }

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
