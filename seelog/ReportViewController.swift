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
    case states
    case cities
    case timezones
    case continents
}

class ReportViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapCellHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: ReportScrollView!
    @IBOutlet weak var historyBarChartView: HistoryChartView!
    @IBOutlet weak var accumulateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var seenAreaButton: UIButton!
    @IBOutlet weak var countriesButton: UIButton!
    @IBOutlet weak var statesButton: UIButton!
    @IBOutlet weak var continentsButton: UIButton!
    @IBOutlet weak var citiesButton: UIButton!
    @IBOutlet weak var timezonesButton: UIButton!

    var mapViewDelegate: MainMapViewDelegate?
    var barChartSelection: ReportBarChartSelection? {
        get {
            return historyBarChartView.barChartSelection
        }
    }

    var aggregateChart: Bool {
        get {
            return accumulateSegmentedControl.selectedSegmentIndex == 0
        }
    }

    var currentTab: SelectedTab = .places

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

        loadData()
        accumulateSegmentedControl.addTarget(self, action: #selector(accumulateStateChanged), for: .valueChanged)

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

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewManager?.numberOfSections() ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewManager?.titleForHeaderInSection(section: section)
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
            switch currentTab {
            case .places:
                tableViewManager = HeatmapTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)

            case .countries, .states:
                tableViewManager = CountriesTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)

            case .cities:
                tableViewManager = CitiesTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)

            case .timezones:
                tableViewManager = TimezonesTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)

            case .continents:
                tableViewManager = ContinentsTableViewManager(year: year, cumulative: aggregateChart, tableView: tableView, geoDB: geoDB)
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let year = barChartSelection?.currentAggregate {
            mapViewDelegate?.load(currentTab: currentTab,
                                  year: year,
                                  cumulative: aggregateChart,
                                  geoDB: geoDB,
                                  context: appDelegate.persistentContainer.viewContext)
        }
    }

    func reloadStatLabel() {
        if let year = barChartSelection?.currentAggregate {
            UIView.setAnimationsEnabled(false)
            self.countriesButton.setTitle("\(year.numberOfCountries(cumulative: aggregateChart)) countries", for: .normal)
            self.statesButton.setTitle("\(year.numberOfStates(cumulative: aggregateChart)) regions", for: .normal)
            self.citiesButton.setTitle("\(year.numberOfCities(cumulative: aggregateChart)) cities", for: .normal)
            self.seenAreaButton.setTitle("\(year.seenArea(cumulative: aggregateChart)) km²", for: .normal)
            self.continentsButton.setTitle("\(year.numberOfContinents(cumulative: aggregateChart, geoDB: geoDB)) continents", for: .normal)
            self.timezonesButton.setTitle("\(year.numberOfTimezones(cumulative: aggregateChart, geoDB: geoDB)) timezones", for: .normal)
            UIView.setAnimationsEnabled(true)
        }
    }

    @IBAction func seenAreaButtonTriggered(_ sender: Any) {
        currentTab = .places
        deselectAllButtons()
        seenAreaButton.isSelected = true
        reloadAllAndScrollChart(false)
    }

    @IBAction func countriesButtonTriggered(_ sender: Any) {
        currentTab = .countries
        deselectAllButtons()
        countriesButton.isSelected = true
        reloadAllAndScrollChart(false)
    }

    @IBAction func statesButtonTriggered(_ sender: Any) {
        currentTab = .states
        deselectAllButtons()
        statesButton.isSelected = true
        reloadAllAndScrollChart(false)
    }

    @IBAction func citiesButtonTriggered(_ sender: Any) {
        currentTab = .cities
        deselectAllButtons()
        citiesButton.isSelected = true
        reloadAllAndScrollChart(false)
    }

    @IBAction func continentsButtonTriggered(_ sender: Any) {
        currentTab = .continents
        deselectAllButtons()
        continentsButton.isSelected = true
        reloadAllAndScrollChart(false)
    }

    @IBAction func timezonesButtonTriggered(_ sender: Any) {
        currentTab = .timezones
        deselectAllButtons()
        timezonesButton.isSelected = true
        reloadAllAndScrollChart(false)
    }
    
    private func deselectAllButtons() {
        seenAreaButton.isSelected = false
        countriesButton.isSelected = false
        statesButton.isSelected = false
        citiesButton.isSelected = false
        continentsButton.isSelected = false
        timezonesButton.isSelected = false
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
