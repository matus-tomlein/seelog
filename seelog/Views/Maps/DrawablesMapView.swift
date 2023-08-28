//
//  CountriesChartView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/08/2023.
//  Copyright © 2023 Matus Tomlein. All rights reserved.
//

import SwiftUI
import MapKit
import GEOSwiftMapKit
import GEOSwift

struct DrawablesMapView: View {
    var borderDrawables: [Drawable]?
    var drawables: [Drawable]
    var cities: [City]?
    
    @State var zoomType: ZoomType = .far
    @State var mapRegion: MKCoordinateRegion?
    @State var selection: (location: CGPoint, country: Country?, region: Region?, continent: Continent?, timezone: Timezone?, city: City?)?
    
    func isSelected(_ drawable: Drawable) -> Bool {
        if let country = selection?.country { return country._id == drawable._id }
        if let region = selection?.region { return region._id == drawable._id }
        if let timezone = selection?.timezone { return timezone._id == drawable._id }
        if let continent = selection?.continent { return continent._id == drawable._id }
        return false
    }
    
    func isSelected(_ city: City) -> Bool {
        if let selected = selection?.city { return selected.id == city.id }
        return false
    }
    
    func polygons(_ drawable: Drawable) -> [Polygon] {
        if zoomType == .far { return drawable.polygons(zoomType: .far) }
        if let mapRegion = $mapRegion.wrappedValue {
            if drawable.intersects(mapRegion: mapRegion) {
                return drawable.polygons(zoomType: zoomType)
            }
        }
        return drawable.polygons(zoomType: .far)
    }
    
    var body: some View {
        MapReader { reader in
            Map {
                if let borderDrawables {
                    ForEach(borderDrawables, id: \._id) { drawable in
                        ForEach(polygons(drawable), id: \.hashValue) { polygon in
                            MapPolygon(MKPolygon(polygon: polygon))
//                                .foregroundStyle(Color.clear)
//                                .stroke(Color.red)
                                .foregroundStyle(isSelected(drawable) ? .red : .gray.opacity(0.5))
                                .stroke(Color.white)
                                .stroke(lineWidth: 10)
                        }
                    }
                }
                ForEach(drawables, id: \._id) { drawable in
                    ForEach(polygons(drawable), id: \.hashValue) { polygon in
                        MapPolygon(MKPolygon(polygon: polygon))
                            .foregroundStyle(isSelected(drawable) ? .red : .red.opacity(0.5))
                            .stroke(Color.white)
                            .stroke(lineWidth: 10)
                    }
                }
                if let cities {
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
            }
            .onTapGesture(perform: { location in
                if let point = reader.convert(location, from: .local) {
                    if selection?.location == location { return }
                    self.selection = nil
                    for drawable in drawables {
                        for polygon in drawable.polygons(zoomType: .far) {
                            if (try? polygon.intersects(Point(point))) ?? false {
                                switch drawable {
                                case let country as Country:
                                    self.selection = (location: location, country: country, region: nil, continent: nil, timezone: nil, city: nil)
                                    
                                case let region as Region:
                                    self.selection = (location: location, country: nil, region: region, continent: nil, timezone: nil, city: nil)
                                    
                                case let continent as Continent:
                                    self.selection = (location: location, country: nil, region: nil, continent: continent, timezone: nil, city: nil)
                                    
                                case let timezone as Timezone:
                                    self.selection = (location: location, country: nil, region: nil, continent: nil, timezone: timezone, city: nil)
                                    
                                default: break
                                }
                                break
                            }
                        }
                    }
                }
            })
            .onMapCameraChange(frequency: .onEnd) { context in
                self.zoomType = ZoomType.zoomTypeForMapRect(context.rect)
                self.mapRegion = context.region
            }
        }
        //        .navigationBarTitle(title)
        .navigationBarItems(
            trailing: Button(action: {}, label: {
                if let country = selection?.country {
                    NavigationLink(destination: CountryView(country: country)) {
                        Text(country.countryInfo.name)
                    }
                }
                else if let continent = selection?.continent {
                    NavigationLink(destination: ContinentView(continent: continent)) {
                        Text(continent.continentInfo.name)
                    }
                }
                else if let region = selection?.region {
                    NavigationLink(destination: StateView(state: region)) {
                        Text(region.stateInfo.name)
                    }
                }
                else if let timezone = selection?.timezone {
                    NavigationLink(destination: TimezoneView(timezone: timezone)) {
                        Text(timezone.timezoneInfo.name)
                    }
                }
                else if let city = selection?.city {
                    NavigationLink(destination: CityView(city: city)) {
                        Text(city.cityInfo.name)
                    }
                }
            }))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CountriesMapView_Previews: PreviewProvider {
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return DrawablesMapView(drawables: model.countries, cities: model.cities)
    }
}
