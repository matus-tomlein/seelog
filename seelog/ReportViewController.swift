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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left += 15
        view.layoutMargins.right += 15

        historyBarChartView.reportViewController = self

        mapViewDelegate = MainMapViewDelegate(mapView: mapView)
        mapView.delegate = mapViewDelegate

        reloadForCurrentContent()
        contentSegmentedControl.addTarget(self, action: #selector(reloadForCurrentContent), for: .valueChanged)

        reloadForCurrentGranularityChanged()
        granularitySegmentedControl.addTarget(self, action: #selector(reloadForCurrentGranularityChanged), for: .valueChanged)

        aggregateChartSwitch.addTarget(self, action: #selector(aggregateChartSwitchStateChanged(_:)), for: .valueChanged)

        scrollView.setContentOffset(CGPoint(
            x: scrollView.contentOffset.x,
            y: scrollView.contentOffset.y + 75
        ), animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { context in
            self.collectionView.layoutIfNeeded()
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            self.collectionViewHeightConstraint.constant = contentSize.height
        }, completion: nil)
    }

    func reloadData() {
        collectionView.reloadData()

        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        collectionViewHeightConstraint.constant = contentSize.height
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.barChartSelection?.currentCountries?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReportSelectionCollectionViewCell
        cell.label.text = self.barChartSelection?.flaggedItems?[indexPath.row]
        return cell
    }

    @objc func reloadForCurrentContent() {
        self.numberOfVisitedCountriesLabel.text = String(barChartSelection?.countries?.count ?? 0) + " countries"

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        if contentSegmentedControl.selectedSegmentIndex == 0 {
            mapViewDelegate?.loadMapViewHeatmap()
        } else if contentSegmentedControl.selectedSegmentIndex == 1 {
            mapViewDelegate?.loadMapViewCountries()
        } else if contentSegmentedControl.selectedSegmentIndex == 2 {
            mapViewDelegate?.loadMapViewCities()
        }
    }

    @objc func reloadForCurrentGranularityChanged() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        if let barChartSelection = self.barChartSelection {
            switch granularitySegmentedControl.selectedSegmentIndex {
            case 0: // years
                barChartSelection.changeGranularity(.years, context: context)
                break

            case 1: // seasons
                barChartSelection.changeGranularity(.seasons, context: context)
                break

            case 2: // months
                barChartSelection.changeGranularity(.months, context: context)
                break

            default:
                break
            }
        }

        historyBarChartView.load()
        barChartSelection?.clear()
    }

    @objc func aggregateChartSwitchStateChanged(_ aggregateSwitch: UISwitch) {
        historyBarChartView.changeChartType()
        historyBarChartView.update()
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
