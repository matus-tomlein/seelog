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
import QuickLook

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

class ReportViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapCellHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: ReportScrollView!
    @IBOutlet weak var historyBarChartView: HistoryChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var seenAreaButton: UIButton!
    @IBOutlet weak var countriesButton: UIButton!
    @IBOutlet weak var statesButton: UIButton!
    @IBOutlet weak var continentsButton: UIButton!
    @IBOutlet weak var citiesButton: UIButton!
    @IBOutlet weak var timezonesButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    var mapViewDelegate: MainMapViewDelegate?
    var barChartSelection: ReportBarChartSelection? {
        get {
            return historyBarChartView.barChartSelection
        }
    }

    var aggregateChart: Bool {
        get {
            return barChartSelection?.cumulative ?? true
        }
    }

    var currentTab: SelectedTab = .places
    var geoDB = GeoDatabase()
    private var purchasedHistory: CompleteHistoryPurchase?
    private var hasPurchasedHistory: Bool { get { return CompleteHistoryPurchase.isPurchased } }
    private var visitPeriodManager: VisitPeriodManager?
    private var placeStatsManager: PlaceStatsManager?

    private var context: NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.persistentContainer.viewContext
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left += 15
        view.layoutMargins.right += 15

        let height = UIScreen.main.bounds.height
        mapCellHeight.constant = height - 220
        tableView.isScrollEnabled = false
        tableView.bounces = false

        historyBarChartView.reportViewController = self

        mapView.region = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
        mapViewDelegate = MainMapViewDelegate(mapView: mapView, reportViewController: self)
        mapView.delegate = mapViewDelegate

        scrollView.delegate = self

        loadData()

        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseFailedNotification(_:)),
                                               name: .IAPHelperPurchaseFailedNotification,
                                               object: nil)

        CompleteHistoryPurchase.fetch { purchase in
            self.purchasedHistory = purchase
            let formatter = NumberFormatter()

            formatter.formatterBehavior = .behavior10_4
            formatter.numberStyle = .currency
            formatter.locale = purchase.product.priceLocale
            let priceLabel = formatter.string(from: purchase.product.price)
            DispatchQueue.main.async {
                self.buyButton.setTitle(priceLabel, for: .normal)
            }
        }

        self.visitPeriodManager = VisitPeriodManager(context: context)
        self.placeStatsManager = PlaceStatsManager(context: context)
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

    func quickLookImages(assets: [PHAsset]) {
        let dataSource = ImagePreviewDataSource(assets: assets, reportViewController: self)
        dataSource.load()
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
        reloadStatLabel()
        if scrollChart {
            reloadBarChart()
        } else {
            updateBarChart()
        }

        DispatchQueue.main.async {
            self.reloadTableView()
            self.reloadMap()
        }
    }

    func reloadTableView() {
        let reloadTableViewCallback = {
            self.tableView.reloadData()
            // TODO: this is slow:
            for section in 0..<self.numberOfSections(in: self.tableView) {
                for cell in 0..<self.tableView(self.tableView, numberOfRowsInSection: section) {
                    self.tableView.rectForRow(at: IndexPath(row: cell, section: section))
                }
            }
            self.tableViewHeight.constant = max(UIScreen.main.bounds.height - self.searchBar.frame.height, self.tableView.contentSize.height)
        }

        if let year = barChartSelection?.currentAggregate {
            if aggregateChart {
                if let placeStatsManager = placeStatsManager {
                tableViewManager = PlaceStatsTableViewManager(placeStatsManager: placeStatsManager,
                                                              searchQuery: searchBar.text ?? "",
                                                              currentTab: currentTab,
                                                              tableView: tableView,
                                                              reloadTableViewCallback: reloadTableViewCallback,
                                                              geoDB: geoDB)
                }
            } else {
                if let visitPeriodManager = visitPeriodManager {
                    tableViewManager = VisitPeriodsTableViewManager(visitPeriodManager: visitPeriodManager,
                                                                    year: year, cumulative: aggregateChart,
                                                                    searchQuery: searchBar.text ?? "",
                                                                    purchasedHistory: hasPurchasedHistory,
                                                                    currentTab: currentTab,
                                                                    tableView: tableView,
                                                                    reloadTableViewCallback: reloadTableViewCallback,
                                                                    geoDB: geoDB)
                }
            }
        }

        reloadTableViewCallback()
    }

    func reloadBarChart() {
        historyBarChartView.load(purchasedHistory: hasPurchasedHistory)
    }

    func updateBarChart() {
        historyBarChartView.update(purchasedHistory: hasPurchasedHistory)
    }

    @objc func reloadMap() {
        if let year = barChartSelection?.currentAggregate {
            mapViewDelegate?.load(currentTab: currentTab,
                                  year: year,
                                  cumulative: aggregateChart,
                                  purchasedHistory: hasPurchasedHistory,
                                  geoDB: geoDB,
                                  context: context)
        }
    }

    func reloadStatLabel() {
        if let year = barChartSelection?.currentAggregate {
            UIView.setAnimationsEnabled(false)
            if !year.isLocked(purchasedHistory: hasPurchasedHistory) {
                buttonsView.isHidden = false
                purchaseView.isHidden = true

                self.countriesButton.setTitle("\(year.numberOfCountries(cumulative: aggregateChart)) countries", for: .normal)
                self.statesButton.setTitle("\(year.numberOfStates(cumulative: aggregateChart)) regions", for: .normal)
                self.citiesButton.setTitle("\(year.numberOfCities(cumulative: aggregateChart)) cities", for: .normal)
                let seenArea = year.seenArea(cumulative: aggregateChart)
                let seenAreaFormatted = NumberFormatter.localizedString(from: NSNumber(value: seenArea), number: .decimal)
                self.seenAreaButton.setTitle("\(seenAreaFormatted) km²", for: .normal)
                self.continentsButton.setTitle("\(year.numberOfContinents(cumulative: aggregateChart)) continents", for: .normal)
                self.timezonesButton.setTitle("\(year.numberOfTimezones(cumulative: aggregateChart, geoDB: geoDB)) timezones", for: .normal)
            } else {
                buttonsView.isHidden = true
                purchaseView.isHidden = false
            }

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
        self.barChartSelection?.loadItems(context: context)
    }

    // MARK: purchases

    @objc func handlePurchaseNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.reloadAll()
        }
    }

    @objc func handlePurchaseFailedNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func buyButtonPressed(_ sender: Any) {
        if IAPHelper.canMakePayments() {
            if let purchasedHistory = self.purchasedHistory {
                openLoadingAlert()
                purchasedHistory.buy()
            }
        } else {
            let alert = UIAlertController(title: "Can't Make Payments", message: "Sorry, you are not allowed to make payments.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func restoreButtonPressed(_ sender: Any) {
        if let purchasedHistory = self.purchasedHistory {
            openLoadingAlert()
            purchasedHistory.restore()
        }
    }

    func openLoadingAlert() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Scroll View

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            tableViewManager?.scrolledToBottom()
        }

        if searchBarEditing {
            endSearchEditing()
        }
    }

    // MARK: - Search bar

    private var searchBarEditing = false
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        scrollView.contentOffset = searchBar.frame.origin
        if let superviewY = searchBar.superview?.frame.origin.y {
            scrollView.contentOffset = CGPoint(x: 0, y: superviewY + searchBar.frame.origin.y)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.searchBarEditing = true
        }
    }

    private func endSearchEditing() {
        searchBar.endEditing(true)
        self.searchBarEditing = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearchEditing()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableViewManager?.setSearchQuery(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        endSearchEditing()
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
