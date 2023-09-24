//
//  TrippablesListItemView.swift
//  seelog
//
//  Created by Matus Tomlein on 23/09/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TrippableListItemView: View {
    var trippable: Trippable
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewState: ViewState
    @ObservedObject var selectedYearState: SelectedYearState
    var year: Int? { return selectedYearState.year }
    var maxStayDuration: Int?
    
    var body: some View {
        if let maxStayDuration {
            NavigationLink(
                destination: TrippableView(trippable: trippable, selectedYearState: selectedYearState)
                    .environmentObject(self.viewState)
            ) {
                GeometryReader { proxy in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(trippable.nameWithFlag)
                                .font(.headline)
                            Spacer()
                            if trippable.isNew(year: year) {
                                Text("🆕")
                            }
                        }.padding(0)
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(
                                    width: barWidth(proxy.size.width, maxStayDuration: maxStayDuration),
                                    height: 25
                                )
                                .foregroundColor(colorScheme == .dark ? .gray : Color(UIColor.lightGray))
                            Text(trippable.stayDurationInfo(year: year))
                                .font(.callout)
                                .padding(.leading, 5)
                        }.padding(0)
                    }.padding(0)
                }
                .frame(height: 60)
            }
        } else {
            NavigationLink(
                destination: TrippableView(trippable: trippable, selectedYearState: selectedYearState)
                    .environmentObject(self.viewState)
            ) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(trippable.nameWithFlag)
                            .font(.headline)
                        Spacer()
                        if trippable.isNew(year: year) {
                            Text("🆕")
                        }
                    }.padding(0)
                    Text(trippable.stayDurationInfo(year: year))
                        .font(.callout)
                        .foregroundColor(.gray)
                }.padding(0)
            }
        }
    }
    
    func barWidth(_ totalWidth: CGFloat, maxStayDuration: Int) -> CGFloat {
        return maxStayDuration > 0 ? CGFloat(trippable.stayDurationForYear(year)) / CGFloat(maxStayDuration) * totalWidth : CGFloat.zero
    }
}
