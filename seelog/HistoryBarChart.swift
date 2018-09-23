//
//  HistoryBarChart.swift
//  seelog
//
//  Created by Matus Tomlein on 22/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit

struct BarEntry {
    let color: UIColor

    /// Ranged from 0.0 to 1.0
    let height: Float

    /// To be shown on top of the bar
    let textValue: String

    /// To be shown at the bottom of the bar
    let title: String

    let items: [String]
}

class HistoryBarChart: UIView {

    /// the width of each bar
    let barWidth: CGFloat = 40.0

    /// space between each bar
    let space: CGFloat = 20.0

    /// space at the bottom of the bar to show the title
    private let bottomSpace: CGFloat = 40.0

    /// space at the top of each bar to show the value
    private let topSpace: CGFloat = 40.0

    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()

    var barChartSelection: ReportBarChartSelection?

    var dataEntries: [BarEntry]? = nil {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})

            if let dataEntries = dataEntries {
                scrollView.contentSize = CGSize(width: (barWidth + space)*CGFloat(dataEntries.count), height: self.frame.size.height)
                mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)

                for i in 0..<dataEntries.count {
                    showEntry(index: i, entry: dataEntries[i])
                }

                let bottomOffset = CGPoint(x: self.scrollView.contentSize.width - self.scrollView.bounds.size.width, y: 0)
                self.scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
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
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.scrollView.addGestureRecognizer(recognizer)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: scrollView)

            guard let sublayers = self.mainLayer.sublayers else { return }

            for layer in sublayers {
                if layer.frame.contains(point) {
                    if let title = layer.name,
                        let dataEntries = self.dataEntries {
                        for entry in dataEntries {
                            if entry.title == title {
                                self.barChartSelection?.items = entry.items
                            }
                        }
                        selectBar(with: title)
                    }
                }
            }
        }
    }

    func selectBar(with name: String) {
        guard let sublayers = self.mainLayer.sublayers else { return }
        for layer in sublayers {
            let color: CGColor = layer.name == name ? #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1) : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            if let textLayer = layer as? CATextLayer {
                textLayer.foregroundColor = color
            } else {
                layer.backgroundColor = color
            }
        }
    }

    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }

    private func showEntry(index: Int, entry: BarEntry) {
        /// Starting x postion of the bar
        let xPos: CGFloat = space + CGFloat(index) * (barWidth + space)

        /// Starting y postion of the bar
        let yPos: CGFloat = translateHeightValueToYPosition(value: entry.height)

        drawBar(xPos: xPos, yPos: yPos, color: entry.color, name: entry.title)

        /// Draw text above the bar
        drawTextValue(xPos: xPos - space/2, yPos: yPos - 30, textValue: entry.textValue, color: entry.color, name: entry.title)

        /// Draw text below the bar
        drawTitle(xPos: xPos - space/2, yPos: mainLayer.frame.height - bottomSpace + 10, title: entry.title, color: entry.color)
    }

    private func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor, name: String) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height - bottomSpace - yPos)
        barLayer.backgroundColor = color.cgColor
        barLayer.name = name
        mainLayer.addSublayer(barLayer)
    }

    private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor, name: String) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth+space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = textValue
        textLayer.name = name
        mainLayer.addSublayer(textLayer)
    }

    private func drawTitle(xPos: CGFloat, yPos: CGFloat, title: String, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth + space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = title
        textLayer.name = title
        mainLayer.addSublayer(textLayer)
    }

    private func translateHeightValueToYPosition(value: Float) -> CGFloat {
        let height: CGFloat = CGFloat(value) * (mainLayer.frame.height - bottomSpace - topSpace)
        return mainLayer.frame.height - bottomSpace - height
    }

}
