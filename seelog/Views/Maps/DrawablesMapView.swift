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
    
    @State var selectedCountry: Country? = nil
    @State var selectedRegion: Region? = nil
    @State var selectedContinent: Continent? = nil
    @State var selectedTimezone: Timezone? = nil
    @State var selectedCity: City? = nil
    @ObservedObject var selectedYearState: SelectedYearState
    
    @State var selectedLocation: CGPoint?
    @State var zoomType: ZoomType = .far
    @State var mapRegion: MKCoordinateRegion?
    @State var isActive = false
    
    init(borderDrawables: [Drawable]? = nil, drawables: [Drawable], cities: [City]? = nil, selectedYearState: SelectedYearState) {
        self.borderDrawables = borderDrawables
        self.drawables = drawables
        self.cities = cities
        self.selectedYearState = selectedYearState
        self.zoomType = zoomType
        self.mapRegion = mapRegion
    }
    
    func polygons(_ drawable: Drawable) -> [Polygon] {
        if zoomType == .far { return drawable.polygons(zoomType: .far) }
        if let mapRegion = $mapRegion.wrappedValue {
            let drawableRegion = drawable.coordinateRegion
            if Helpers.intersects(mapRegion1: drawableRegion, mapRegion2: mapRegion) {
                return drawable.polygons(zoomType: zoomType)
            }
        }
        return drawable.polygons(zoomType: .far)
    }
    
    var initialPosition: MapCameraPosition {
        if let borderDrawables {
            if borderDrawables.count == 1 {
                if let coordinateRegion = borderDrawables.first?.coordinateRegion {
                    return .region(coordinateRegion)
                }
            }
        }
        return .automatic
    }
    
    var body: some View {
        MapReader { reader in
            Map(initialPosition: initialPosition) {
                if let borderDrawables {
                    ForEach(borderDrawables, id: \._id) { drawable in
                        ForEach(polygons(drawable), id: \.hashValue) { polygon in
                            MapPolygon(MKPolygon(polygon: polygon))
                                .foregroundStyle(.gray.opacity(0.5))
                                .stroke(Color.white)
                                .stroke(lineWidth: 10)
                        }
                    }
                }
                ForEach(drawables, id: \._id) { drawable in
                    ForEach(polygons(drawable), id: \.hashValue) { polygon in
                        MapPolygon(MKPolygon(polygon: polygon))
                            .foregroundStyle(.red.opacity(0.5))
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
                    if selectedLocation == location || isActive { return }
                    if selectedLocation != nil { clearSelection() }
                    var found = false
                    for drawable in drawables {
                        for polygon in drawable.polygons(zoomType: .far) {
                            if (try? polygon.intersects(Point(point))) ?? false {
                                found = true
                                switch drawable {
                                case let country as Country:
                                    selectedCountry = country
                                    
                                case let region as Region:
                                    selectedRegion = region
                                    
                                case let continent as Continent:
                                    selectedContinent = continent
                                    
                                case let timezone as Timezone:
                                    selectedTimezone = timezone
                                    
                                default:
                                    found = false
                                }
                                break
                            }
                        }
                    }
                    if found {
                        selectedLocation = location
                        isActive = true
                    } else {
                        clearSelection()
                    }
                }
            })
            .onMapCameraChange(frequency: .onEnd) { context in
                self.zoomType = ZoomType.zoomTypeForMapRect(context.rect)
                self.mapRegion = context.region
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if selectedLocation != nil && isActive {
                    Button(action: {}, label: {
                        if let country = selectedCountry {
                            NavigationLink(
                                destination: CountryView(
                                    country: country,
                                    selectedYearState: selectedYearState
                                ), isActive: $isActive) {
                            }
                        }
                        else if let continent = selectedContinent {
                            NavigationLink(
                                destination: ContinentView(
                                    continent: continent,
                                    selectedYearState: selectedYearState
                                ), isActive: $isActive) {
                            }
                        }
                        else if let region = selectedRegion {
                            NavigationLink(
                                destination: StateView(
                                    state: region,
                                    selectedYearState: selectedYearState
                                ), isActive: $isActive) {
                            }
                        }
                        else if let timezone = selectedTimezone {
                            NavigationLink(
                                destination: TimezoneView(
                                    timezone: timezone,
                                    selectedYearState: selectedYearState
                                ), isActive: $isActive) {
                            }
                        }
                        else if let city = selectedCity {
                            NavigationLink(
                                destination: CityView(
                                    city: city,
                                    selectedYearState: selectedYearState
                                ), isActive: $isActive) {
                            }
                        }
                    })
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func clearSelection() {
        selectedLocation = nil
        selectedCountry = nil
        selectedRegion = nil
        selectedContinent = nil
        selectedTimezone = nil
    }
}

struct DrawablesMapView_Previews: PreviewProvider {
    @State static var selected: Drawable? = nil
    
    static var previews: some View {
        let model = simulatedDomainModel()
        
        return DrawablesMapView(
            drawables: model.countries,
            cities: model.cities,
            selectedYearState: SelectedYearState()
        )
    }
}
