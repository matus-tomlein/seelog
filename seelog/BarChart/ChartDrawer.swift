//
//  ChartDrawer.swift
//  seelog
//
//  Created by Matus Tomlein on 27/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

class ChartDrawer {

    internal let barWidth: CGFloat = 40.0
    internal let space: CGFloat = 20.0
    internal let bottomSpace: CGFloat = 40.0
    internal let topSpace: CGFloat = 40.0

    internal let view: UIView
    internal let scrollView: UIScrollView
    internal let mainLayer: CALayer
    internal let barChartSelection: ReportBarChartSelection

    internal let color: UIColor
    internal var unselectedBarColor: UIColor { get { return view.tintColor } }
    internal let selectedColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)

    private let deselectedLock = UIImage(named: "deselected_lock")?.cgImage
    private let selectedLock = UIImage(named: "selected_lock")?.cgImage

    private var recognizer: UIGestureRecognizer?

    init(view: UIView, mainLayer: CALayer, scrollView: UIScrollView, barChartSelection: ReportBarChartSelection) {
        self.view = view
        self.mainLayer = mainLayer
        self.scrollView = scrollView
        self.barChartSelection = barChartSelection
        self.color = view.tintColor

        recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.scrollView.addGestureRecognizer(recognizer!)
    }

    func loadAndScroll(purchasedHistory: Bool) {
        load(purchasedHistory: purchasedHistory)
        scrollToRight()
    }

    func load(purchasedHistory: Bool) {}

    func unload() {
        if let recognizer = self.recognizer {
            scrollView.removeGestureRecognizer(recognizer)
            self.recognizer = nil
        }
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: scrollView)
            if let layer = getLayer(for: point),
                let title = layer.name {
                let year = yearFrom(name: title)
                let cumulative = isCumulativeFrom(name: title)

                if year != barChartSelection.currentSelection || cumulative != barChartSelection.cumulative {
                    barChartSelection.currentSelection = year
                    barChartSelection.cumulative = cumulative
                    barChartSelection.reload()
                    deselectAll()
                    selectBar(year: year, cumulative: cumulative)
                }
            }
        }
    }

    func deselectAll() {
        guard let sublayers = self.mainLayer.sublayers else { return }
        for layer in sublayers {
            if let textLayer = layer as? CATextLayer {
                textLayer.foregroundColor = color.cgColor
            } else if layer.name?.starts(with: "visible-") ?? false {
                if layer.contents != nil {
                    layer.contents = deselectedLock
                } else {
                    layer.backgroundColor = unselectedBarColor.cgColor
                }
            }
        }
    }

    func selectBar(year: String, cumulative: Bool) {
        let name = nameFor(year: year, cumulative: cumulative)
        guard let sublayers = self.mainLayer.sublayers else { return }
        for layer in sublayers {
            if layer.name == "visible-" + name {
                if let textLayer = layer as? CATextLayer {
                    textLayer.foregroundColor = selectedColor.cgColor
                } else if let shapeLayer = layer as? CAShapeLayer {
                    shapeLayer.fillColor = selectedColor.cgColor
                    shapeLayer.strokeColor = selectedColor.cgColor
                } else {
                    if layer.contents != nil {
                        layer.contents = selectedLock
                    } else {
                        layer.backgroundColor = selectedColor.cgColor
                    }
                }
            }
        }
    }

    func getLayer(for point: CGPoint) -> CALayer? {
        guard let sublayers = self.mainLayer.sublayers else { return nil }

        for layer in sublayers {
            if layer.frame.contains(point) && !(layer.name?.starts(with: "visible-") ?? true) {
                return layer
            }
        }

        return nil
    }

    internal func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor, year: String) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height - bottomSpace - yPos)
        barLayer.backgroundColor = color.cgColor
        barLayer.name = "visible-" + nameFor(year: year, cumulative: false)
        mainLayer.addSublayer(barLayer)
    }

    internal func drawTotalBar(xPos: CGFloat, color: UIColor, year: String) {
        let name = nameFor(year: year, cumulative: true)

        let linePathBottom = UIBezierPath()
        let height = mainLayer.frame.height
        linePathBottom.move(to: CGPoint(x: xPos,
                                  y: height - bottomSpace))
        linePathBottom.addLine(to: CGPoint(x: xPos + barWidth,
                                     y: height - bottomSpace))
        linePathBottom.addLine(to: CGPoint(x: xPos + barWidth,
                                     y: translateHeightValueToYPosition(value: 0.75)))
        linePathBottom.addLine(to: CGPoint(x: xPos,
                                     y: translateHeightValueToYPosition(value: 0.65)))
        linePathBottom.addLine(to: CGPoint(x: xPos,
                                     y: height - bottomSpace))

        let shapeLayerBottom = CAShapeLayer()
        shapeLayerBottom.fillColor = color.cgColor
        shapeLayerBottom.strokeColor = color.cgColor
        shapeLayerBottom.name = "visible-" + name
        mainLayer.addSublayer(shapeLayerBottom)
        shapeLayerBottom.path = linePathBottom.cgPath

        let linePathTop = UIBezierPath()
        linePathTop.move(to: CGPoint(x: xPos,
                                        y: translateHeightValueToYPosition(value: 0.7)))
        linePathTop.addLine(to: CGPoint(x: xPos + barWidth,
                                           y: translateHeightValueToYPosition(value: 0.8)))
        linePathTop.addLine(to: CGPoint(x: xPos + barWidth,
                                           y: translateHeightValueToYPosition(value: 1)))
        linePathTop.addLine(to: CGPoint(x: xPos,
                                           y: translateHeightValueToYPosition(value: 1)))
        linePathTop.addLine(to: CGPoint(x: xPos,
                                           y: translateHeightValueToYPosition(value: 0.7)))

        let shapeLayerTop = CAShapeLayer()
        shapeLayerTop.fillColor = color.cgColor
        shapeLayerTop.strokeColor = color.cgColor
        shapeLayerTop.name = "visible-" + name
        mainLayer.addSublayer(shapeLayerTop)
        shapeLayerTop.path = linePathTop.cgPath
    }

    internal func nameFor(year: String, cumulative: Bool) -> String {
        return year + (cumulative ? "1" : "0")
    }

    internal func isCumulativeFrom(name: String) -> Bool {
        return name.last == "1"
    }

    internal func yearFrom(name: String) -> String {
        return String(name.dropLast())
    }

    internal func drawSelectionArea(xPos: CGFloat, year: String, cumulative: Bool) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos,
                                y: 0,
                                width: barWidth + space,
                                height: mainLayer.frame.height)
        barLayer.backgroundColor = UIColor.clear.cgColor
        barLayer.name = nameFor(year: year, cumulative: cumulative)
        mainLayer.addSublayer(barLayer)
    }

    internal func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor, year: String, cumulative: Bool) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth+space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = textValue
        textLayer.name = "visible-" + nameFor(year: year, cumulative: cumulative)
        mainLayer.addSublayer(textLayer)
    }

    internal func drawTitle(xPos: CGFloat, yPos: CGFloat, title: String, year: String, cumulative: Bool, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth + space, height: 40)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = title
        textLayer.name = "visible-" + nameFor(year: year, cumulative: cumulative)
        mainLayer.addSublayer(textLayer)
    }

    internal func drawBarLabel(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor, year: Year, cumulative: Bool, purchasedHistory: Bool) {
        if year.isLocked(purchasedHistory: purchasedHistory) {
            let imageLayer = CALayer()
            imageLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth+space, height: 22)
            imageLayer.contents = deselectedLock
            imageLayer.contentsGravity = kCAGravityResizeAspect
            imageLayer.name = "visible-" + year.name
            mainLayer.addSublayer(imageLayer)
        } else {
            drawTextValue(xPos: xPos,
                          yPos: yPos,
                          textValue: textValue,
                          color: color,
                          year: year.name,
                          cumulative: cumulative)
        }
    }

    internal func translateHeightValueToYPosition(value: Float) -> CGFloat {
        let height: CGFloat = CGFloat(value) * (mainLayer.frame.height - bottomSpace - topSpace)
        return mainLayer.frame.height - bottomSpace - height
    }

    internal func setFrameSize(numberOfItems: Int) {
        scrollView.contentSize = CGSize(width: (barWidth + space) * CGFloat(numberOfItems) + 24, height: view.frame.size.height)
        mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
    }

    internal func scrollToRight() {
        let bottomOffset = CGPoint(x: self.scrollView.contentSize.width - self.scrollView.bounds.size.width, y: 0)
        self.scrollView.setContentOffset(bottomOffset, animated: false)
    }

}
