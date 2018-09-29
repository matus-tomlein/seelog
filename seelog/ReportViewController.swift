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

class ReportViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var numberOfVisitedCountriesLabel: UILabel!
    @IBOutlet weak var historyBarChartView: HistoryBarChart!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var granularitySegmentedControl: UISegmentedControl!

    var barChartSelection: ReportBarChartSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins.left += 15
        view.layoutMargins.right += 15

        self.barChartSelection = ReportBarChartSelection(reportViewController: self)
        historyBarChartView.barChartSelection = self.barChartSelection

        reloadForCurrentGranularityChanged()
        granularitySegmentedControl.addTarget(self, action: #selector(reloadForCurrentGranularityChanged), for: .valueChanged)

        self.numberOfVisitedCountriesLabel.text = String(barChartSelection?.countries?.count ?? 0) + " countries"
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

    @objc func reloadForCurrentGranularityChanged() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        switch granularitySegmentedControl.selectedSegmentIndex {
        case 0: // years
            barChartSelection?.loadEntries(granularity: .years, context: context)
            break

        case 1: // seasons
            barChartSelection?.loadEntries(granularity: .seasons, context: context)
            break

        case 2: // months
            barChartSelection?.loadEntries(granularity: .months, context: context)
            break

        default:
            break
        }

        historyBarChartView.loadEntries()
        if barChartSelection?.currentSelection != nil {
            barChartSelection?.currentSelection = nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
