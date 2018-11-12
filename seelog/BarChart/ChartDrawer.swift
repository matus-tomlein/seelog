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

    func loadAndScroll() {
        load()
        scrollToRight()
    }

    func load() {}

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
                if title != barChartSelection.currentSelection {
                    barChartSelection.currentSelection = title
                    barChartSelection.reload()
                    deselectAll()
                    selectBar(with: title)
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
                layer.backgroundColor = unselectedBarColor.cgColor
            }
        }
    }

    func selectBar(with name: String) {
        guard let sublayers = self.mainLayer.sublayers else { return }
        for layer in sublayers {
            if layer.name == "visible-" + name {
                if let textLayer = layer as? CATextLayer {
                    textLayer.foregroundColor = selectedColor.cgColor
                } else {
                    layer.backgroundColor = selectedColor.cgColor
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

    internal func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor, name: String) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height - bottomSpace - yPos)
        barLayer.backgroundColor = color.cgColor
        barLayer.name = "visible-" + name
        mainLayer.addSublayer(barLayer)
    }

    internal func drawSelectionArea(xPos: CGFloat, name: String) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos,
                                y: 0,
                                width: barWidth + space,
                                height: mainLayer.frame.height)
        barLayer.backgroundColor = UIColor.clear.cgColor
        barLayer.name = name
        mainLayer.addSublayer(barLayer)
    }

    internal func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor, name: String) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth+space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = textValue
        textLayer.name = "visible-" + name
        mainLayer.addSublayer(textLayer)
    }

    internal func drawTitle(xPos: CGFloat, yPos: CGFloat, title: String, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth + space, height: 40)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = title
        textLayer.name = "visible-" + title
        mainLayer.addSublayer(textLayer)
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
