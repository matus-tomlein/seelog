//
//  BarChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 12/01/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct BarChartView: View {
    var yearStats: [(year: Int, count: Int)]
    var barUnitHeight: Int {
        get {
            return 170 / max(1, yearStats.map { $0.count }.max() ?? 1)
        }
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom) {
                VStack(alignment: .center) {
                    Text("Total")
                        .foregroundColor(Color(UIColor.systemBlue))
                        .fontWeight(.semibold)
                    Rectangle()
                        .fill(Color(UIColor.systemBlue))
                        .frame(width: 50, height: 56)
                    Rectangle()
                        .fill(Color(UIColor.systemBlue))
                        .frame(width: 50, height: 106)
                    Text("Total")
                        .foregroundColor(Color(UIColor.systemBlue))
                        .fontWeight(.semibold)
                }
                .padding(.leading, 20)
                .padding(.trailing, 35)

                ForEach(yearStats, id: \.year) { stat in
                    VStack(alignment: .center) {
                        Text(String(stat.count))
                            .foregroundColor(Color(UIColor.systemOrange))
                            .fontWeight(.semibold)
                        Rectangle()
                            .fill(Color(UIColor.systemOrange))
                            .frame(
                                width: 50,
                                height: CGFloat(self.barUnitHeight * stat.count)
                            )
                        Text(String(stat.year))
                            .foregroundColor(Color(UIColor.systemOrange))
                            .fontWeight(.semibold)
                    }
                    .padding(.trailing, 10)
                }
            }
        }
//        }.offset(100)
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BarChartView(
                yearStats: [
                    (year: 2020, count: 5),
                    (year: 2019, count: 4),
                    (year: 2018, count: 1)
                ]
            )
        }
    }
}
