//
//  BadgeView.swift
//  seelog
//
//  Created by Matus Tomlein on 07/03/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct BadgeView: View {
    var geometryDescription: GeometryDescription
    var foregroundColor: Color = .white
    var backgroundColor: Color = .red
    
    var body: some View {
        ZStack {
            PolygonView(
                shapes: [
                    (geometryDescription: geometryDescription, color: backgroundColor, opacity: 1)
                ],
                points: [],
                rectangles: [],
                minX: geometryDescription.minX,
                maxX: geometryDescription.maxX,
                minY: geometryDescription.minY,
                maxY: geometryDescription.maxY
            )
                .frame(width: 100, height: 100, alignment: .center)
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .overlay(Circle().stroke(foregroundColor, lineWidth: 7))
                .shadow(radius: 10)
            Text("✔")
                .font(.custom("Zapf Dingbats", size: 60))
                .foregroundColor(foregroundColor)
                .shadow(radius: 10)
        }
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        let geoDB = GeoDatabase()
//        let country = geoDB.countryInfoFor(countryKey: "ESP")
//        let geometry = country!.geometry50mDescription
        let continent = geoDB.continentInfoFor(name: "Europe")!
        let geometry = continent.geometryDescription
        return BadgeView(geometryDescription: geometry)
    }
}
