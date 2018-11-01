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
    @IBOutlet weak var granularitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: ReportScrollView!
    @IBOutlet weak var contentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aggregateChartSwitch: UISwitch!
    @IBOutlet weak var mapCellHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    var mapViewDelegate: MainMapViewDelegate?
    var barChartSelection: ReportBarChartSelection? {
        get {
            return historyBarChartView.barChartSelection
        }
    }

    var aggregateChart: Bool {
        get {
            return aggregateChartSwitch.isOn
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

    var granularity: Granularity {
        get {
            switch granularitySegmentedControl.selectedSegmentIndex {
            case 0: // years
                return .years

            case 1: // seasons
                return .seasons

            default: // months
                return .months
            }
        }
    }

    var geoDB = GeoDatabase()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left += 15
        view.layoutMargins.right += 15

        mapCellHeight.constant = 600
        tableView.isScrollEnabled = false

        historyBarChartView.reportViewController = self

        mapViewDelegate = MainMapViewDelegate(mapView: mapView)
        mapView.delegate = mapViewDelegate

        contentSegmentedControl.addTarget(self, action: #selector(reloadAll), for: .valueChanged)

        loadData()
        granularitySegmentedControl.addTarget(self, action: #selector(changeGranularity), for: .valueChanged)

        aggregateChartSwitch.addTarget(self, action: #selector(aggregateChartSwitchStateChanged(_:)), for: .valueChanged)

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.barChartSelection?.currentCountries?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell

        if let countryKey = self.barChartSelection?.currentCountries?[indexPath.row] {
            cell.iconLabel.text = Helpers.flag(country: countryKey)
            cell.descriptionLabel.text = geoDB.countryInfoFor(countryKey: countryKey)?.name

            if let states = self.barChartSelection?.currentCountriesAndStates?[countryKey] {
                cell.subTextLabel.text = states.map({ geoDB.stateInfoFor(stateKey: $0)?.name ?? "" }).sorted().joined(separator: ", ")
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: reloading

    @objc func reloadAll() {
        reloadAllAndScrollChart(true)
    }

    func reloadAllAndScrollChart(_ scrollChart: Bool) {
        reloadMap()
        if scrollChart {
            reloadBarChart()
        } else {
            updateBarChart()
        }
        reloadStatLabel()
        reloadTableView()
    }

    func reloadTableView() {
        tableView.reloadData()

        self.tableView.layoutIfNeeded()
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

    @objc func changeGranularity() {
        loadData()
        barChartSelection?.clear()
        reloadAll()
    }

    private func loadData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.barChartSelection?.loadItems(context: context)
    }

    @objc func aggregateChartSwitchStateChanged(_ aggregateSwitch: UISwitch) {
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
