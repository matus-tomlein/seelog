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

class ReportViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var numberOfVisitedCountriesLabel: UILabel!
    @IBOutlet weak var historyBarChartView: HistoryChartView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var granularitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: ReportScrollView!
    @IBOutlet weak var contentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aggregateChartSwitch: UISwitch!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left += 15
        view.layoutMargins.right += 15

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
            self.collectionView.layoutIfNeeded()
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            self.collectionViewHeightConstraint.constant = contentSize.height
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.barChartSelection?.currentCountries?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReportSelectionCollectionViewCell
        cell.label.text = self.barChartSelection?.flaggedItems?[indexPath.row]
        return cell
    }

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
        reloadCollectionView()
    }

    func reloadCollectionView() {
        collectionView.reloadData()

        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        collectionViewHeightConstraint.constant = contentSize.height
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
            mapViewDelegate?.loadMapViewCountries(barChartSelection: barChartSelection)
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
