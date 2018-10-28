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
                let t = properties.zoomTypes.map({ $0.rawValue }).joined() + properties.polygonType.rawValue + "\(properties.alpha)"
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
    var heatmapPolygon: Geometry?

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

    func loadMapViewCountries() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        if let visitedCountries = VisitedCountry.all(context: context) {
            let geoDB = GeoDatabase()
            for country in visitedCountries {
                if let stateKeys = country.stateKeys {
                    for stateKey in stateKeys {
                        if let stateInfo = geoDB.stateInfoFor(stateKey: stateKey) {
                            var closeZoomTypes: [ZoomType] = [.close]
                            if let geometry50m = stateInfo.geometry50m {
                                let polygonProperties = PolygonProperties(zoomTypes: [.medium], polygonType: .state, alpha: 0.5)
                                addGeometryToMap(geometry50m, polygonProperties: polygonProperties)
                            } else {
                                closeZoomTypes.append(.medium)
                            }
                            if let geometry10m = stateInfo.geometry10m {
                                let polygonProperties = PolygonProperties(zoomTypes: closeZoomTypes, polygonType: .state, alpha: 0.5)
                                addGeometryToMap(geometry10m, polygonProperties: polygonProperties)
                            }

                            let annotation = StateAnnotation(title: stateInfo.name, coordinate: CLLocationCoordinate2D(latitude: stateInfo.latitude, longitude: stateInfo.longitude))
                            mapView.addAnnotation(annotation)
                        }
                    }
                }

                if let countryKey = country.countryKey,
                    let countryInfo = geoDB.countryInfoFor(countryKey: countryKey) {
                    var closeZoomTypes: [ZoomType] = [.close]
                    var mediumZoomTypes: [ZoomType] = [.medium]

                    if let geometry110m = countryInfo.geometry110m {
                        let polygonProperties = PolygonProperties(zoomTypes: [.far], polygonType: .country, alpha: 0.2)
                        addGeometryToMap(geometry110m, polygonProperties: polygonProperties)
                    } else {
                        mediumZoomTypes.append(.far)
                    }
                    if let geometry50m = countryInfo.geometry50m {
                        let polygonProperties = PolygonProperties(zoomTypes: mediumZoomTypes, polygonType: .country, alpha: 0.2)
                        addGeometryToMap(geometry50m, polygonProperties: polygonProperties)
                    } else {
                        for zoomType in mediumZoomTypes {
                            closeZoomTypes.append(zoomType)
                        }
                    }
                    if let geometry10m = countryInfo.geometry10m {
                        let polygonProperties = PolygonProperties(zoomTypes: closeZoomTypes, polygonType: .country, alpha: 0.2)
                        addGeometryToMap(geometry10m, polygonProperties: polygonProperties)
                    }

                    let annotation = CountryAnnotation(title: countryInfo.name, coordinate: CLLocationCoordinate2D(latitude: countryInfo.latitude, longitude: countryInfo.longitude))
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }

    func loadMapViewHeatmap() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        if let wkt = Year.last(context: context)?.cumulativeHeatmapWKT {
            if let polygon = Helpers.geometry(fromWKT: wkt) {
                self.heatmapPolygon = polygon
            }
        }

        if let polygon = self.heatmapPolygon {
            addGeometryToMap(polygon, polygonProperties: PolygonProperties(zoomTypes: [.close, .medium, .far], polygonType: .heatmap, alpha: 0.8))
        }
    }

    func loadMapViewCities() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        if let visitedCities = VisitedCity.all(context: context) {
            let geoDB = GeoDatabase()
            for city in visitedCities {
                if let cityInfo = geoDB.cityInfoFor(cityKey: city.cityKey) {
                    let annotation = CityAnnotation(title: cityInfo.name, coordinate: CLLocationCoordinate2D(latitude: cityInfo.latitude, longitude: cityInfo.longitude))
                    mapView.addAnnotation(annotation)
                }
            }
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
}
