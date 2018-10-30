//
//  MainMapViewDelegate.swift
//  seelog
//
//  Created by Matus Tomlein on 20/10/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit
import MapKit
import GEOSwift

class Annotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var zoomTypes: [ZoomType] {
        get { return [.close, .medium, .far] }
    }

    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return title
    }
}

class CityAnnotation: Annotation {}
class CountryAnnotation: Annotation {}
class StateAnnotation: Annotation {
    override var zoomTypes: [ZoomType] {
        get { return [.close] }
    }
}

enum ZoomType: String {
    case close = "close"
    case medium = "medium"
    case far = "far"
}

enum PolygonType: String {
    case heatmap = "heatmap"
    case country = "country"
    case state = "state"
}

struct PolygonProperties {
    var name: String
    var zoomTypes: [ZoomType]
    var polygonType: PolygonType
    var alpha: CGFloat = 1
}

extension MKPolygon {
    private static var allPolygonProperties = [String: PolygonProperties]()

    var polygonProperties: PolygonProperties? {
        get {
            if let title = self.title {
                return MKPolygon.allPolygonProperties[title]
            }
            return nil
        }
        set(properties) {
            if let properties = properties {
                let t = properties.zoomTypes.map({ $0.rawValue }).joined() + properties.polygonType.rawValue + "\(properties.alpha)" + properties.name
                title = t
                MKPolygon.allPolygonProperties[t] = properties
            }
        }
    }
}

class PolygonRenderer: MKPolygonRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
//        print(zoomScale)
        let currentZoomType: ZoomType = zoomScale > 0.0001 ? .close : (zoomScale > 0.00002 ? .medium : .far)
        if let zoomTypes = polygon.polygonProperties?.zoomTypes {
            if !zoomTypes.contains(currentZoomType) {
                return
            }
        }
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}

class MainMapViewDelegate: NSObject, MKMapViewDelegate {
    var mapView: MKMapView

    init(mapView: MKMapView) {
        self.mapView = mapView
    }

    var currentZoomType: ZoomType = .close {
        didSet {
            guard oldValue != currentZoomType else {
                return
            }

            for case let annot as Annotation in mapView.annotations {
                mapView.view(for: annot)?.isHidden = !annot.zoomTypes.contains(currentZoomType)
            }
        }
    }

    func loadMapViewCountries(barChartSelection: ReportBarChartSelection?) {
        let geoDB = GeoDatabase()

        var existingPolygonProperties = [PolygonProperties]()
        for overlay in mapView.overlays {
            if let polygon = overlay as? MKPolygon,
                let polygonProperties = polygon.polygonProperties {
                existingPolygonProperties.append(polygonProperties)
            }
        }

        var polygonPropertyNamesToKeep = Set<String>()
        if let visitedCountriesAndStates = barChartSelection?.currentAggregate?.countries(cumulative: barChartSelection?.aggregateChart ?? true) {
            for countryKey in visitedCountriesAndStates.keys {
                if let stateKeys = visitedCountriesAndStates[countryKey] {
                    for stateKey in stateKeys {
                        let existing = existingPolygonProperties.filter({ $0.name == stateKey })
                        if existing.count == 0 {
                            createPolygon(forStateKey: stateKey, geoDB: geoDB)
                        }

                        polygonPropertyNamesToKeep.insert(stateKey)
                    }
                }

                let existing = existingPolygonProperties.filter({ $0.name == countryKey })
                if existing.count == 0 {
                    createPolygon(forCountryKey: countryKey, geoDB: geoDB)
                }

                polygonPropertyNamesToKeep.insert(countryKey)
            }
        }

        for overlay in mapView.overlays {
            if let polygon = overlay as? MKPolygon,
                let polygonProperties = polygon.polygonProperties {
                if !polygonPropertyNamesToKeep.contains(polygonProperties.name) {
                    mapView.remove(overlay)
                }
            }
        }
    }

    func loadMapViewHeatmap(barChartSelection: ReportBarChartSelection?) {
        mapView.removeOverlays(mapView.overlays)

        if let wkt = barChartSelection?.currentAggregate?.heatmapWKT(cumulative: barChartSelection?.aggregateChart ?? true),
            let polygon = Helpers.geometry(fromWKT: wkt) {
            addGeometryToMap(polygon, polygonProperties: PolygonProperties(name: barChartSelection!.currentSelection!,
                                                                           zoomTypes: [.close, .medium, .far],
                                                                           polygonType: .heatmap,
                                                                           alpha: 0.8))
        }
    }

    func addGeometryToMap(_ geometry: Geometry, polygonProperties: PolygonProperties) {
        if let polygon = geometry.mapShape() as? MKPolygon {
            polygon.polygonProperties = polygonProperties
            mapView.add(polygon)
        } else if let shapes = geometry.mapShape() as? MKShapesCollection {
            for shape in shapes.shapes {
                if let polygon = shape as? MKPolygon {
                    polygon.polygonProperties = polygonProperties
                    mapView.add(polygon)
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon,
            let polygonProperties = polygon.polygonProperties {
            let isCountry = polygonProperties.polygonType == .country
            let isHeatmap = polygonProperties.polygonType == .heatmap
            let color = isHeatmap ? UIColor.black : UIColor.red
            let polygonView = PolygonRenderer(overlay: overlay) // TODO: reuse polygon renderer?
            polygonView.fillColor = color.withAlphaComponent(polygonProperties.alpha)
            if isCountry || isHeatmap {
                polygonView.lineWidth = 1
                polygonView.strokeColor = UIColor.white
            }
//            polygonView.alpha = polygonProperties.zoomTypes.contains(currentZoomType) ? 1 : 0
            return polygonView
        }
        return MKPolylineRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else { return nil }
        // 3
        var identifier = "marker"
        switch annotation {
        case is CityAnnotation:
            identifier = "city"
        case is CountryAnnotation:
            identifier = "country"
        case is StateAnnotation:
            identifier = "state"
        default:
            identifier = "marker"
        }

        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            if annotation is StateAnnotation {
                view.markerTintColor = UIColor.lightGray
                view.displayPriority = .defaultLow
                view.alpha = 0
            } else if annotation is CountryAnnotation {
                view.displayPriority = .defaultHigh
            }
        }
        view.isHidden = !annotation.zoomTypes.contains(currentZoomType)
        return view
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.region.span.latitudeDelta < 7.5 {
            currentZoomType = .close
        } else if mapView.region.span.latitudeDelta < 15 {
            currentZoomType = .medium
        } else {
            currentZoomType = .far
        }
    }

    private func createPolygon(forStateKey stateKey: String, geoDB: GeoDatabase) {
        if let stateInfo = geoDB.stateInfoFor(stateKey: stateKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            if let geometry50m = stateInfo.geometry50m {
                let polygonProperties = PolygonProperties(name: stateKey,
                                                          zoomTypes: [.medium],
                                                          polygonType: .state,
                                                          alpha: 0.5)
                addGeometryToMap(geometry50m, polygonProperties: polygonProperties)
            } else {
                closeZoomTypes.append(.medium)
            }
            if let geometry10m = stateInfo.geometry10m {
                let polygonProperties = PolygonProperties(name: stateKey,
                                                          zoomTypes: closeZoomTypes,
                                                          polygonType: .state,
                                                          alpha: 0.5)
                addGeometryToMap(geometry10m, polygonProperties: polygonProperties)
            }
        }
    }

    private func createPolygon(forCountryKey countryKey: String, geoDB: GeoDatabase) {
        if let countryInfo = geoDB.countryInfoFor(countryKey: countryKey) {
            var closeZoomTypes: [ZoomType] = [.close]
            var mediumZoomTypes: [ZoomType] = [.medium]

            if let geometry110m = countryInfo.geometry110m {
                let polygonProperties = PolygonProperties(name: countryKey,
                                                          zoomTypes: [.far],
                                                          polygonType: .country,
                                                          alpha: 0.2)
                addGeometryToMap(geometry110m, polygonProperties: polygonProperties)
            } else {
                mediumZoomTypes.append(.far)
            }
            if let geometry50m = countryInfo.geometry50m {
                let polygonProperties = PolygonProperties(name: countryKey,
                                                          zoomTypes: mediumZoomTypes,
                                                          polygonType: .country,
                                                          alpha: 0.2)
                addGeometryToMap(geometry50m, polygonProperties: polygonProperties)
            } else {
                for zoomType in mediumZoomTypes {
                    closeZoomTypes.append(zoomType)
                }
            }
            if let geometry10m = countryInfo.geometry10m {
                let polygonProperties = PolygonProperties(name: countryKey,
                                                          zoomTypes: closeZoomTypes,
                                                          polygonType: .country,
                                                          alpha: 0.2)
                addGeometryToMap(geometry10m, polygonProperties: polygonProperties)
            }
        }
    }

}
