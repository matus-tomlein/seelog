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
    private var chartDrawer: LineChartDrawer?

    var reportViewController: ReportViewController? {
        didSet {
            if let reportViewController = self.reportViewController {
                chartDrawer = LineChartDrawer(view: self,
                                             mainLayer: mainLayer,
                                             scrollView: scrollView,
                                             reportViewController: reportViewController)
            }
        }
    }

    func loadEntries(reportViewController: ReportViewController) {
        chartDrawer?.loadEntries()
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

    private func setupView() {
        scrollView.preservesSuperviewLayoutMargins = true
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
    }


    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }


}
