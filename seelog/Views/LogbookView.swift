//
//  LogbookView.swift
//  seelog
//
//  Created by Matus Tomlein on 26/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LogbookView: View {
    @EnvironmentObject var viewState: ViewState
    var year: Int? { return viewState.selectedYear }
    var model: DomainModel { return viewState.model }
    
    var seenGeometry: SeenGeometry? { get { return model.seenGeometry(year: year) } }
    var yearStats: [(year: Int, count: Int)] {
        return model.years.reversed().map { year in
            let distance = year.seenGeometry?.travelledDistance ?? 0

            return (
                year: year.year,
                count: Int(distance)
            )
        }
    }

    var body: some View {
        List {
            VStack(spacing: 0) {
                WorldView(
                    background: (continents: model.continentInfos, countries: [], regions: []),
                    foreground: (continents: [], countries: [], regions: [], timezones: []),
                    cities: [],
                    positions: seenGeometry?.higherLevelPositions ?? [],
                    detailed: false,
                    opaque: false,
                    showPositionsAsDots: true
                )

            }.listRowInsets(EdgeInsets())

            BarChartView(
                showCounts: true,
                yearStats: yearStats
            )
            
            ForEach(TextInfoGenerator.travelledDistance(model: self.model
            , year: year)) { textInfo in
                TextInfoView(info: textInfo)
            }

            ForEach(TextInfoGenerator.countries(model: self.model
            , year: year)) { textInfo in
                TextInfoView(info: textInfo)
            }

            ForEach(TextInfoGenerator.cities(model: self.model
            , year: year)) { textInfo in
                TextInfoView(info: textInfo)
            }

            ForEach(TextInfoGenerator.continents(model: self.model
            , year: year)) { textInfo in
                TextInfoView(info: textInfo)
            }

            ForEach(TextInfoGenerator.timezones(model: self.model
            , year: year)) { textInfo in
                TextInfoView(info: textInfo)
            }
        }
        .navigationBarTitle("Hey Explorer!")
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return LogbookView().environmentObject(ViewState(model: model))
    }
}
