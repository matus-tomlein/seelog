//
//  LineChartDrawer.swift
//  seelog
//
//  Created by Matus Tomlein on 26/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class LineChartDrawer: ChartDrawer {

    override internal var unselectedBarColor: UIColor { get { return UIColor.clear } }

    override init(view: UIView, mainLayer: CALayer, scrollView: UIScrollView, barChartSelection: ReportBarChartSelection) {
        super.init(view: view, mainLayer: mainLayer, scrollView: scrollView, barChartSelection: barChartSelection)
    }

    override func load() {
        mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        
        let linePath = UIBezierPath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = color.cgColor
        shapeLayer.strokeColor = color.cgColor
        mainLayer.addSublayer(shapeLayer)

        if let aggregates = barChartSelection.aggregates {
            setFrameSize(numberOfItems: aggregates.count)

            let height = mainLayer.frame.height
            linePath.move(to: CGPoint(x: 0,
                                      y: height - bottomSpace))

            let maxCount = aggregates.map { $0.chartValue(selectedTab: barChartSelection.currentTab, cumulative: true) }.max() ?? 0

            for i in 0 ..< aggregates.count {
                let aggregate = aggregates[i]
                let value = aggregate.chartValue(selectedTab: barChartSelection.currentTab, cumulative: true)
                let pointHeight = Float(value) / Float(maxCount)

                let xPos: CGFloat = space + CGFloat(i) * (barWidth + space) + barWidth / 2
                let yPos: CGFloat = translateHeightValueToYPosition(value: pointHeight)

                linePath.addLine(to: CGPoint(x: xPos,
                                             y: yPos))

                drawBar(xPos: xPos - barWidth / 2,
                        yPos: yPos,
                        color: unselectedBarColor,
                        name: aggregate.name)

                drawTitle(xPos: xPos - space * 1.5,
                          yPos: mainLayer.frame.height - bottomSpace + 5,
                          title: aggregate.name,
                          color: color)

                drawTextValue(xPos: xPos - space * 1.5,
                              yPos: yPos - 30,
                              textValue: aggregate.chartLabel(selectedTab: barChartSelection.currentTab, cumulative: true),
                              color: color,
                              name: aggregate.name)

                drawSelectionArea(xPos: xPos - space / 2,
                                  name: aggregate.name)
            }

            linePath.addLine(to: CGPoint(x: space + CGFloat(aggregates.count - 1) * (barWidth + space) + barWidth / 2,
                                         y: height - bottomSpace))

            if let currentSelection = barChartSelection.currentSelection {
                selectBar(with: currentSelection)
            }
        }

        shapeLayer.path = linePath.cgPath
    }

}
