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

    var barChartSelection: ReportBarChartSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.barChartSelection = ReportBarChartSelection(reportViewController: self)
        historyBarChartView.barChartSelection = self.barChartSelection

        self.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        let dataEntries = generateDataEntries()
        self.historyBarChartView.dataEntries = dataEntries
    }

    func generateDataEntries() -> [BarEntry] {
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
        var result: [BarEntry] = []

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<Year>(entityName: "Year")
        request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
        do {
            let years = try context.fetch(request)
            let maxCount = years.map { ($0.countries ?? []).count }.max() ?? 0

            for year in years {
                let value = year.countries?.count ?? 0
                let height: Float = Float(value) / Float(maxCount)

                result.append(BarEntry(
                    color: colors[1],
                    height: height,
                    textValue: "\(value)",
                    title: String(year.year),
                    items: year.countries ?? []
                ))
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return result
    }

    func load() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.propertiesToFetch = ["countryKey"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        var countries: [String] = []
        do {
            let results = try context.fetch(fetchRequest)
            let resultsDict = results as! [[String: String]]

            for r in resultsDict {
                if let countryKey = r["countryKey"] {
                    countries.append(countryKey)
                }
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }

        self.numberOfVisitedCountriesLabel.text = "Visited " +
            String(countries.count) + " countries"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.barChartSelection?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReportSelectionCollectionViewCell
        cell.label.text = self.barChartSelection?.flaggedItems[indexPath.row]
        return cell
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
