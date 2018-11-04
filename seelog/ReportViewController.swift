//
//  ReportViewController.swift
//  seelog
//
//  Created by Matus Tomlein on 22/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit
import Photos
import CoreData
import MapKit
import GEOSwift

class ReportScrollView: UIScrollView {
    @IBOutlet weak var mapOverlayView: UIView!

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return point.y > mapOverlayView.frame.maxY
    }
}

enum SelectedTab {
    case places
    case countries
}

class ReportViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var numberOfVisitedCountriesLabel: UILabel!
    @IBOutlet weak var historyBarChartView: HistoryChartView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: ReportScrollView!
    @IBOutlet weak var contentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapCellHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var accumulateSegmentedContent: UISegmentedControl!

    var mapViewDelegate: MainMapViewDelegate?
    var barChartSelection: ReportBarChartSelection? {
        get {
            return historyBarChartView.barChartSelection
        }
    }

    var aggregateChart: Bool {
        get {
            return accumulateSegmentedContent.selectedSegmentIndex == 0
        }
    }

    var currentTab: SelectedTab {
        get {
            if contentSegmentedControl.selectedSegmentIndex == 0 {
                return .places
            }
            return .countries
        }
    }

    var geoDB = GeoDatabase()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left += 15
        view.layoutMargins.right += 15

        mapCellHeight.constant = 600
        tableView.isScrollEnabled = false
        tableView.bounces = false

        historyBarChartView.reportViewController = self

        mapViewDelegate = MainMapViewDelegate(mapView: mapView)
        mapView.delegate = mapViewDelegate

        contentSegmentedControl.addTarget(self, action: #selector(reloadAll), for: .valueChanged)

        loadData()
        accumulateSegmentedContent.addTarget(self, action: #selector(accumulateStateChanged), for: .valueChanged)

        scrollView.setContentOffset(CGPoint(
            x: scrollView.contentOffset.x,
            y: scrollView.contentOffset.y + 75
        ), animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        reloadAll()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { context in
            self.tableView.layoutIfNeeded()
            let contentSize = self.tableView.contentSize
            self.tableViewHeight.constant = contentSize.height
        }, completion: nil)
    }

    // MARK: Table view

    var tableViewManager: TableViewManager?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewManager?.numberOfRowsInSection(section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewManager!.cellForRowAt(indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: reloading

    @objc func reloadAll() {
        reloadAllAndScrollChart(true)
    }

    func reloadAllAndScrollChart(_ scrollChart: Bool) {
        if scrollChart {
            reloadBarChart()
        } else {
            updateBarChart()
        }
        reloadStatLabel()
        reloadTableView()
        reloadMap()
    }

    func reloadTableView() {
        if let year = barChartSelection?.currentAggregate {
            if currentTab == .countries {
                tableViewManager = CountriesTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)
            } else if currentTab == .places {
                tableViewManager = HeatmapTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)
            }
        }
        tableView.reloadData()
        for cell in 0..<tableView(tableView, numberOfRowsInSection: 0) {
            tableView.rectForRow(at: IndexPath(row: cell, section: 0))
        }
        tableViewHeight.constant = tableView.contentSize.height
    }

    func reloadBarChart() {
        historyBarChartView.load()
    }

    func updateBarChart() {
        historyBarChartView.update()
    }

    @objc func reloadMap() {
        if currentTab == .places {
            mapViewDelegate?.loadMapViewHeatmap(barChartSelection: barChartSelection)
        } else if currentTab == .countries {
            mapViewDelegate?.loadMapViewCountries(barChartSelection: barChartSelection, geoDB: geoDB)
        }
    }

    func reloadStatLabel() {
        let value = barChartSelection?.currentAggregate?.chartValue(selectedTab: currentTab, cumulative: aggregateChart) ?? 0

        if currentTab == .places {
            numberOfVisitedCountriesLabel.text = String(Int(round(value))) + " km²"
        } else if currentTab == .countries {
            numberOfVisitedCountriesLabel.text = String(Int(round(value))) + " countries"
        }
    }

    private func loadData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.barChartSelection?.loadItems(context: context)
    }

    @objc func accumulateStateChanged() {
        historyBarChartView.changeChartType()
        reloadAllAndScrollChart(false)
    }

    // MARK: - Map view


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
