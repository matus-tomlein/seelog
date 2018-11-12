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
import CoreData

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
    case heatmapWater = "hw"
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
    var mapManager: MapManager?

    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init()

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(recognizer)
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
    }

    var currentZoomType: ZoomType = .close {
        didSet {
            guard oldValue != currentZoomType else {
                return
            }

            mapManager?.updateForZoomType(currentZoomType)
        }
    }

    @objc func longPress(gestureRecognizer: UIGestureRecognizer) {
        mapManager?.longPress()
    }

    func load(currentTab: SelectedTab, year: Year, cumulative: Bool, geoDB: GeoDatabase, context: NSManagedObjectContext) {
        switch currentTab {
        case .countries, .states:
            if let mapManager = self.mapManager as? CountriesMapManager {
                mapManager.load(currentTab: currentTab, year: year, cumulative: cumulative)
            } else {
                mapManager?.unload()
                mapManager = CountriesMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
                mapManager?.load(currentTab: currentTab, year: year, cumulative: cumulative)
            }

        case .places:
            if let mapManager = self.mapManager as? HeatmapMapManager {
                mapManager.load(currentTab: currentTab, year: year, cumulative: cumulative)
            } else {
                mapManager?.unload()
                mapManager = HeatmapMapManager(mapView: mapView, mapViewDelegate: self, context: context)
                mapManager?.load(currentTab: currentTab, year: year, cumulative: cumulative)
            }

        case .cities:
            if let mapManager = self.mapManager as? CitiesMapManager {
                mapManager.load(currentTab: currentTab, year: year, cumulative: cumulative)
            } else {
                mapManager?.unload()
                mapManager = CitiesMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
                mapManager?.load(currentTab: currentTab, year: year, cumulative: cumulative)
            }

        case .continents:
            if let mapManager = self.mapManager as? ContinentsMapManager {
                mapManager.load(currentTab: currentTab, year: year, cumulative: cumulative)
            } else {
                mapManager?.unload()
                mapManager = ContinentsMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
                mapManager?.load(currentTab: currentTab, year: year, cumulative: cumulative)
            }

        case .timezones:
            if let mapManager = self.mapManager as? TimezoneMapManager {
                mapManager.load(currentTab: currentTab, year: year, cumulative: cumulative)
            } else {
                mapManager?.unload()
                mapManager = TimezoneMapManager(mapView: mapView, mapViewDelegate: self, geoDB: geoDB)
                mapManager?.load(currentTab: currentTab, year: year, cumulative: cumulative)
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
        if let polygon = overlay as? MKPolygon {
            return mapManager?.rendererFor(polygon: polygon) ?? MKOverlayRenderer(overlay: overlay)
        } else {
            return mapManager?.nonPolygonRendererFor(overlay: overlay) ?? MKOverlayRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapManager?.viewFor(annotation: annotation)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.region.span.latitudeDelta < 7.5 {
            currentZoomType = .close
        } else if mapView.region.span.latitudeDelta < 15 {
            currentZoomType = .medium
        } else {
            currentZoomType = .far
        }

        mapManager?.viewChanged(visibleMapRect: mapView.visibleMapRect)
    }

}
