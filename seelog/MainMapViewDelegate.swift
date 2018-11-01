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
    case close = "c"
    case medium = "m"
    case far = "f"
}

enum PolygonType: String {
    case heatmap = "h"
    case heatmapLand = "hl"
    case country = "c"
    case state = "s"
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
    var landsPolygon: Geometry?
    var waterPolygon: Geometry?

    init(mapView: MKMapView) {
        self.mapView = mapView

        if let landsPath = Bundle.main.path(forResource: "lands", ofType: "wkt") {
            do {
                landsPolygon = try MultiPolygon(WKT: String(contentsOfFile: landsPath,
                                                            encoding: String.Encoding.utf8))
                if let landsPolygon = self.landsPolygon {
                    self.landsPolygon = Helpers.blankWorldwidePolygon().intersection(landsPolygon)
                    waterPolygon = Helpers.blankWorldwidePolygon().difference(landsPolygon)
                }
            } catch { }
        }

        super.init()

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(recognizer)
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

    var lastActiveLongPress: TimeInterval?
    @objc func longPress(gestureRecognizer: UIGestureRecognizer) {
        if lastActiveLongPress == nil {
            setHeatmapPolygonTransparency(alpha: 0.5)
        }
        lastActiveLongPress = Date().timeIntervalSince1970
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.resetLongPress()
        }
    }

    func resetLongPress() {
        guard let lastActiveLongPress = self.lastActiveLongPress else { return }
        if Date().timeIntervalSince1970 - lastActiveLongPress >= 3 {
            setHeatmapPolygonTransparency(alpha: 1)
            self.lastActiveLongPress = nil
        }
    }

    private func setHeatmapPolygonTransparency(alpha: CGFloat) {
        for overlay in mapView.overlays {
            if let polygon = overlay as? MKPolygon,
                let polygonProperties = polygon.polygonProperties {
                if polygonProperties.polygonType == .heatmap || polygonProperties.polygonType == .heatmapLand {
                    mapView.renderer(for: overlay)?.alpha = alpha
                }
            }
        }
    }

    func loadMapViewCountries(barChartSelection: ReportBarChartSelection?, geoDB: GeoDatabase) {
        mapView.mapType = .mutedStandard

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
        mapView.mapType = .hybrid
        mapView.removeOverlays(mapView.overlays)

        if let wkt = barChartSelection?.currentAggregate?.heatmapWKT(cumulative: barChartSelection?.aggregateChart ?? true),
            let heatmap = Helpers.geometry(fromWKT: wkt)?.buffer(width: 0.01),
            let land = landsPolygon?.difference(heatmap),
            let water = waterPolygon?.difference(heatmap) {
            addGeometryToMap(land, polygonProperties: PolygonProperties(name: barChartSelection!.currentSelection!,
                                                                                zoomTypes: [.close, .medium, .far],
                                                                                polygonType: .heatmapLand,
                                                                                alpha: 1))
            addGeometryToMap(water, polygonProperties: PolygonProperties(name: barChartSelection!.currentSelection!,
                                                                           zoomTypes: [.close, .medium, .far],
                                                                           polygonType: .heatmap,
                                                                           alpha: 1))
            if let boundaries = heatmap.boundary()?.mapShape() as? MKShapesCollection {
                for boundary in boundaries.shapes {
                    if let polyline = boundary as? MKPolyline {
                        mapView.add(polyline)
                    }
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
            let isHeatmap = polygonProperties.polygonType == .heatmap || polygonProperties.polygonType == .heatmapLand
            let isHeatmapLand = polygonProperties.polygonType == .heatmapLand
            let color = isHeatmap ? (isHeatmapLand ? #colorLiteral(red: 0.1326935279, green: 0.08801155267, blue: 0.01743199334, alpha: 1) : #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)) : UIColor.red
            let polygonView = PolygonRenderer(overlay: overlay) // TODO: reuse polygon renderer?
            polygonView.fillColor = color.withAlphaComponent(polygonProperties.alpha)
            if isCountry {
                polygonView.lineWidth = 1
                polygonView.strokeColor = UIColor.white
            }
//            polygonView.alpha = polygonProperties.zoomTypes.contains(currentZoomType) ? 1 : 0
            return polygonView
        }
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 1
        renderer.strokeColor = UIColor.white
        return renderer
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
