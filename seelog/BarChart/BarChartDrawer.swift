//
//  BarChartDrawer.swift
//  seelog
//
//  Created by Matus Tomlein on 25/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class BarChartDrawer: ChartDrawer {

    override init(view: UIView, mainLayer: CALayer, scrollView: UIScrollView, barChartSelection: ReportBarChartSelection) {
        super.init(view: view,
                   mainLayer: mainLayer,
                   scrollView: scrollView,
                   barChartSelection: barChartSelection)
    }

    override func load(purchasedHistory: Bool) {
        mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})

        if let aggregates = barChartSelection.aggregates {
            setFrameSize(numberOfItems: aggregates.count + 2)

            let maxCount = aggregates.map { $0.chartValue(selectedTab: barChartSelection.currentTab, cumulative: false, geoDB: barChartSelection.geoDB) }.max() ?? 0

            for i in 0..<aggregates.count {
                let aggregate = aggregates[i]
                let value = aggregate.chartValue(selectedTab: barChartSelection.currentTab, cumulative: false, geoDB: barChartSelection.geoDB)
                let height: Float = Float(value) / Float(maxCount)

                let xPos: CGFloat = space + CGFloat(i) * (barWidth + space)
                let yPos: CGFloat = translateHeightValueToYPosition(value: height)

                drawBar(xPos: xPos,
                        yPos: yPos,
                        color: color,
                        year: aggregate.name)

                drawBarLabel(xPos: xPos - space / 2,
                             yPos: yPos - 30,
                             textValue: aggregate.chartLabel(selectedTab: barChartSelection.currentTab,
                                                             cumulative: false,
                                                             geoDB: barChartSelection.geoDB),
                             color: color,
                             year: aggregate,
                             cumulative: false,
                             purchasedHistory: purchasedHistory)

                drawTitle(xPos: xPos - space / 2,
                          yPos: mainLayer.frame.height - bottomSpace + 5,
                          title: aggregate.name,
                          year: aggregate.name,
                          cumulative: false,
                          color: color)

                drawSelectionArea(xPos: xPos - space / 2,
                                  year: aggregate.name,
                                  cumulative: false)
            }

            if let aggregate = aggregates.last {
                let xPos: CGFloat = space + CGFloat(aggregates.count + 1) * (barWidth + space)
                let yPos: CGFloat = translateHeightValueToYPosition(value: 1)

                drawTotalBar(xPos: xPos, color: color, year: aggregate.name)

                drawBarLabel(xPos: xPos - space / 2,
                             yPos: yPos - 30,
                             textValue: aggregate.chartLabel(selectedTab: barChartSelection.currentTab,
                                                             cumulative: true,
                                                             geoDB: barChartSelection.geoDB),
                             color: color,
                             year: aggregate,
                             cumulative: true,
                             purchasedHistory: purchasedHistory)

                drawTitle(xPos: xPos - space / 2,
                          yPos: mainLayer.frame.height - bottomSpace + 5,
                          title: "Total",
                          year: aggregate.name,
                          cumulative: true,
                          color: color)

                drawSelectionArea(xPos: xPos - space / 2,
                                  year: aggregate.name,
                                  cumulative: true)
            }

            if let currentSelection = barChartSelection.currentSelection {
                selectBar(year: currentSelection, cumulative: barChartSelection.cumulative)
            }
        }
    }

}
