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

    var currentSelection: String? {
        didSet { reportViewController.reloadData() }
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

    init(reportViewController: ReportViewController) {
        self.reportViewController = reportViewController
    }

    func changeGranularity(_ granularity: Granularity, context: NSManagedObjectContext) {
        visitStats.loadItems(granularity: granularity, context: context)
    }

    func clear() {
        currentSelection = nil
    }

}
