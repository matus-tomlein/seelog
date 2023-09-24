//
//  BarChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 12/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct BarChartViewInner: View {
    @ObservedObject var selectedYearState: SelectedYearState
    var showCounts: Bool
    var yearStats: [(year: Int, count: Int)]
    var total: Int?
    let totalBarHeight = 130
    var totalLeadingPadding: CGFloat = 20
    var totalTrailingPadding: CGFloat = 35
    var yearStatsWithoutEmpty: [(year: Int, count: Int)] {
        if yearStats.count > 0 {
            let nonEmptyYears = yearStats.filter { $0.count > 0 }.map { $0.year }
            if let firstYear = nonEmptyYears.min(),
                let lastYear = nonEmptyYears.max() {
                return yearStats.filter { (year, count) in
                    return year >= firstYear && year <= lastYear
                }
            }
        }
        return yearStats
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .center) {
                if showCounts {
                    Text(Helpers.formatShortNumber(Double(self.totalCount())))
                        .foregroundColor(color(nil))
                        .fontWeight(.semibold)
                }
                Rectangle()
                    .fill(color(nil))
                    .frame(width: 50, height: 56)
                Rectangle()
                    .fill(color(nil))
                    .frame(width: 50, height: CGFloat(totalBarHeight - 64))
                Text("Total")
                    .foregroundColor(color(nil))
                    .fontWeight(.semibold)
            }
            .onTapGesture {
                self.selectedYearState.year = nil
            }
            .padding(.leading, totalLeadingPadding)
            .padding(.trailing, totalTrailingPadding)

            ForEach(yearStatsWithoutEmpty, id: \.year) { stat in
                VStack(alignment: .center) {
                    if self.showCounts {
                        Text(Helpers.formatShortNumber(Double(stat.count)))
                            .foregroundColor(self.color(stat.year))
                            .fontWeight(.semibold)
                    }
                    Rectangle()
                        .fill(self.color(stat.year))
                        .frame(
                            width: 50,
                            height: self.barHeight(stat.count)
                        )
                    Text(String(stat.year))
                        .foregroundColor(self.color(stat.year))
                        .fontWeight(.semibold)
                }
                .onTapGesture {
                    self.selectedYearState.year = stat.year
                }
                .padding(.trailing, 10)
            }
        }
//        }.offset(100)
    }

    func barHeight(_ count: Int) -> CGFloat {
        return CGFloat(
            CGFloat(count) *
            CGFloat(totalBarHeight) /
            (yearStats.map { CGFloat($0.count) }.max() ?? CGFloat(1))
        )
    }
    
    func color(_ year: Int?) -> Color {
        if year == self.selectedYearState.year {
            return Color.red
        } else {
            return Color(UIColor.label)
        }
    }
    
    func totalCount() -> Int {
        total ?? yearStats.map { $0.count }.reduce(0, +)
    }

}

struct BarChartView: View {
    @ObservedObject var selectedYearState: SelectedYearState
    var showCounts: Bool
    var yearStats: [(year: Int, count: Int)]
    var total: Int?

    var body: some View {
        ScrollView(.horizontal) {
            BarChartViewInner(selectedYearState: selectedYearState, showCounts: showCounts, yearStats: yearStats, total: total)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BarChartView(
                selectedYearState: SelectedYearState(),
                showCounts: true,
                yearStats: [
                    (year: 2020, count: 180),
                    (year: 2019, count: 4),
                    (year: 2018, count: 1)
                ]
            )
        }
    }
}
