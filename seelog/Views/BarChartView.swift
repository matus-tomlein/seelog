//
//  BarChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 12/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct BarChartViewInner: View {
    @EnvironmentObject var viewState: ViewState
    var showCounts: Bool
    var yearStats: [(year: Int, count: Int)]
    let totalBarHeight = 130
    var totalLeadingPadding: CGFloat = 20
    var totalTrailingPadding: CGFloat = 35

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .center) {
                if showCounts {
                    Text(Helpers.formatNumber(Double(self.totalCount())))
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
                self.viewState.selectedYear = nil
            }
            .padding(.leading, totalLeadingPadding)
            .padding(.trailing, totalTrailingPadding)

            ForEach(yearStats, id: \.year) { stat in
                VStack(alignment: .center) {
                    if self.showCounts {
                        Text(Helpers.formatNumber(Double(stat.count)))
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
                    self.viewState.selectedYear = stat.year
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
        if year == self.viewState.selectedYear {
            return Color.red
        } else {
            return Color(UIColor.label)
        }
    }
    
    func totalCount() -> Int {
        yearStats.map { $0.count }.reduce(0, +)
    }

}


struct BarChartView: View {
    @EnvironmentObject var viewState: ViewState
    var showCounts: Bool
    var yearStats: [(year: Int, count: Int)]

    var body: some View {
        ScrollView(.horizontal) {
            BarChartViewInner(showCounts: showCounts, yearStats: yearStats)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: [], seenGeometries: [], geoDatabase: GeoDatabase())
        return Group {
            return BarChartView(
                showCounts: true,
                yearStats: [
                    (year: 2020, count: 180),
                    (year: 2019, count: 4),
                    (year: 2018, count: 1)
                ]
            ).environmentObject(ViewState(model: model))
        }
    }
}
