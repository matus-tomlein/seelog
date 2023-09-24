//
//  PlacesMapview.swift
//  seelog
//
//  Created by Matus Tomlein on 26/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI
import MapKit
import GEOSwift

struct PlacesMapView: View {
    @EnvironmentObject var viewState: ViewState
    var year: Int?
    var cities: [City] { return viewState.model.citiesForYear(year) }
    
    var polygons: [Polygon] {
        return viewState.model.cache.seenPolygons(year: year, zoomType: zoomType)
    }
    
    @State var zoomType: ZoomType = .far
    @State var mapRegion: MKCoordinateRegion?
    
    var body: some View {
        Map {
            ForEach(polygons, id: \.hashValue) { polygon in
                MapPolygon(MKPolygon(polygon: polygon))
                    .foregroundStyle(.red.opacity(0.5))
                    .stroke(Color.white)
                    .stroke(lineWidth: 10)
            }
            
            ForEach(cities) { city in
                Annotation(city.cityInfo.name, coordinate: CLLocationCoordinate2D(
                    latitude: city.cityInfo.latitude,
                    longitude: city.cityInfo.longitude
                ), anchor: .bottom) {
                    Circle()
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 10, height: 10)
                }
            }

        }
        .onMapCameraChange(frequency: .onEnd) { context in
            self.zoomType = ZoomType.zoomTypeForMapRect(context.rect, threeLevels: false)
            self.mapRegion = context.region
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let model = simulatedDomainModel()
    
    return PlacesMapView()
        .environmentObject(ViewState(model: model))
}
