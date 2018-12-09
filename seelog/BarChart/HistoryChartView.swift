//
//  HistoryBarChart.swift
//  seelog
//
//  Created by Matus Tomlein on 22/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit

class HistoryChartView: UIView {

    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()
    private var chartDrawer: ChartDrawer?

    var barChartSelection: ReportBarChartSelection?

    var reportViewController: ReportViewController? {
        didSet {
            if let reportViewController = self.reportViewController {
                self.barChartSelection = ReportBarChartSelection(reportViewController: reportViewController)
            }
            changeChartType()
        }
    }

    func load(purchasedHistory: Bool) {
        chartDrawer?.loadAndScroll(purchasedHistory: purchasedHistory)
    }

    func update(purchasedHistory: Bool) {
        chartDrawer?.load(purchasedHistory: purchasedHistory)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func changeChartType() {
        if let chartDrawer = self.chartDrawer {
            chartDrawer.unload()
            self.chartDrawer = nil
        }

        if let reportViewController = self.reportViewController,
            let barChartSelection = self.barChartSelection {
            if reportViewController.aggregateChart {
                chartDrawer = LineChartDrawer(view: self,
                                              mainLayer: mainLayer,
                                              scrollView: scrollView,
                                              barChartSelection: barChartSelection)
            } else {
                chartDrawer = BarChartDrawer(view: self,
                                             mainLayer: mainLayer,
                                             scrollView: scrollView,
                                             barChartSelection: barChartSelection)
            }
        }
    }

    private func setupView() {
        scrollView.preservesSuperviewLayoutMargins = true
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
    }


    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }


}
