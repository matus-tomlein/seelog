//
//  CountryPolygon.swift
//  seelog
//
//  Created by Matus Tomlein on 19/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI
import MapKit
import GEOSwiftMapKit

//struct CountryPolygon: MapContentView {
//    var country: Country
//    
//    var body: some View {
//        ForEach(country.countryInfo.geometry10mDescription.polygons, id: \.hashValue) { polygon in
//            
//            MapPolygon(MKPolygon(polygon: polygon))
//                .foregroundStyle(.indigo.opacity(0.7))
//        }
//    }
//}
//
//#Preview {
//    let model = simulatedDomainModel()
//    return Map {
//        CountryPolygon(
//            country: model.countries.first(where: { $0.countryInfo.name == "Hungary" })!
//        )
//    }
//}
