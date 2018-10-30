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
        super.init(view: view, mainLayer: mainLayer, scrollView: scrollView, barChartSelection: barChartSelection)
    }

    override func load() {
        mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})

        if let aggregates = barChartSelection.aggregates {
            setFrameSize(numberOfItems: aggregates.count)

            let maxCount = aggregates.map { $0.chartValue(selectedTab: barChartSelection.currentTab, cumulative: false) }.max() ?? 0

            for i in 0..<aggregates.count {
                let aggregate = aggregates[i]
                let value = aggregate.chartValue(selectedTab: barChartSelection.currentTab, cumulative: false)
                let height: Float = Float(value) / Float(maxCount)

                let xPos: CGFloat = space + CGFloat(i) * (barWidth + space)
                let yPos: CGFloat = translateHeightValueToYPosition(value: height)

                drawBar(xPos: xPos,
                        yPos: yPos,
                        color: color,
                        name: aggregate.name)

                drawTextValue(xPos: xPos - space / 2,
                              yPos: yPos - 30,
                              textValue: aggregate.chartLabel(selectedTab: barChartSelection.currentTab, cumulative: false),
                              color: color,
                              name: aggregate.name)

                drawTitle(xPos: xPos - space / 2,
                          yPos: mainLayer.frame.height - bottomSpace + 5,
                          title: aggregate.name,
                          color: color)

                drawSelectionArea(xPos: xPos - space / 2,
                                  name: aggregate.name)
            }

            if let currentSelection = barChartSelection.currentSelection {
                selectBar(with: currentSelection)
            }
        }
    }

}
