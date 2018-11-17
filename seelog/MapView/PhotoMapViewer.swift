//
//  PhotoMapViewer.swift
//  seelog
//
//  Created by Matus Tomlein on 07/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import Photos

class ImageOverlay : NSObject, MKOverlay {

    var image: UIImage?
    let boundingMapRect: MKMapRect
    let coordinate: CLLocationCoordinate2D

    init(image: UIImage, rect: MKMapRect) {
        self.image = image
        self.boundingMapRect = rect
        self.coordinate = rect.origin.coordinate
    }
}

class ImageOverlayRenderer : MKOverlayRenderer {

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {

        guard let overlay = self.overlay as? ImageOverlay else {
            return
        }

        let rect = self.rect(for: overlay.boundingMapRect)

        if let image = overlay.image {
            UIGraphicsPushContext(context)
            image.draw(in: rect)
            UIGraphicsPopContext()
        }
    }
}

class ImageBorderPolyline: MKPolyline {
    convenience init(rect: MKMapRect) {
        self.init(points: [
            MKMapPointMake(Double(rect.minX), Double(rect.minY)),
            MKMapPointMake(Double(rect.maxX), Double(rect.minY)),
            MKMapPointMake(Double(rect.maxX), Double(rect.maxY)),
            MKMapPointMake(Double(rect.minX), Double(rect.maxY)),
            MKMapPointMake(Double(rect.minX), Double(rect.minY))
        ], count: 5)
    }
}

class PhotoGeohashManager {
    var asset: PHAsset
    var geohash: String
    var mapView: MKMapView
    var circleOverlay: MKCircle?
    var polylineOverlay: ImageBorderPolyline?
    var imageOverlay: ImageOverlay?
    var showingImage = false
    var showingCircle = false

    init(asset: PHAsset, geohash: String, mapView: MKMapView) {
        self.asset = asset
        self.geohash = geohash
        self.mapView = mapView
    }

    func update(viewType: PhotoViewType) {
        switch viewType {
        case .circle:
            showAsCircle()

        case .image:
            showAsImage()

        case .nothing:
            remove()
        }
    }

    func remove() {
        if showingCircle { removeCircle() }
        if showingImage { removeImage() }
    }

    private func showAsCircle() {
        if showingCircle { return }
        showingCircle = true
        self.removeImage()

        DispatchQueue.main.async {
            if let circleOverlay = self.circleOverlay { self.mapView.remove(circleOverlay) }
            let circle = MKCircle(center: CLLocationCoordinate2D(geohash: self.geohash), radius: 1)
            self.mapView.add(circle)
            self.circleOverlay = circle
        }
    }

    private func showAsImage() {
        if showingImage { return }
        showingImage = true
        removeCircle()

        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 640, height: 640),
                                  contentMode: .aspectFit, options: nil,
                                  resultHandler: { (image, info) in
                                    if let image = image {
                                        DispatchQueue.main.async {
                                            self.addImage(image: image)
                                        }
                                    }
        })
    }

    private func removeImage() {
        if !showingImage { return }
        showingImage = false

        if let polylineOverlay = self.polylineOverlay { self.mapView.remove(polylineOverlay) }
        if let imageOverlay = self.imageOverlay {
            self.mapView.remove(imageOverlay)
            imageOverlay.image = nil
        }
        self.polylineOverlay = nil
        self.imageOverlay = nil
    }

    private func removeCircle() {
        if !showingCircle { return }
        showingCircle = false
        if let circleOverlay = circleOverlay { mapView.remove(circleOverlay) }
        circleOverlay = nil
    }

    private func addImage(image: UIImage) {
        if !showingImage { return }
        if let imageOverlay = self.imageOverlay {
            self.mapView.remove(imageOverlay)
            self.imageOverlay = nil
        }

        let multiplyBy = 640 / ([Double(image.size.width), Double(image.size.height)].max() ?? 0)

        let rect = MKMapRect(origin: MKMapPointForCoordinate(CLLocationCoordinate2D(geohash: self.geohash)),
                             size: MKMapSize(width: Double(image.size.width) * multiplyBy, height: Double(image.size.height) * multiplyBy))

        if self.polylineOverlay == nil {
            let polylineOverlay = ImageBorderPolyline(rect: rect)
            mapView.add(polylineOverlay)
            self.polylineOverlay = polylineOverlay
        }

        let imageOverlay = ImageOverlay(image: image,
                                   rect: rect)
        mapView.add(imageOverlay)
        self.imageOverlay = imageOverlay
    }
}

enum PhotoViewType {
    case image
    case circle
    case nothing
}

class LargerGeohashManager {
    var geohash: String
    var loadedPhotoGeohashes: [String: PhotoGeohashManager] = [:]
    var mapView: MKMapView
    var latitude: (min: Double, max: Double)
    var longitude: (min: Double, max: Double)
    var loaded = false
    var year: Int32
    var cumulative: Bool
    var currentViewType = PhotoViewType.nothing

    init(geohash: String, mapView: MKMapView, year: Int32, cumulative: Bool) {
        self.geohash = geohash
        self.mapView = mapView
        self.year = year
        self.cumulative = cumulative
        (latitude, longitude) = Geohash.decode(hash: geohash) ?? ((min: 0, max: 0), (min: 0, max: 0))
    }

    func viewChanged(visibleMapRect: MKMapRect, context: NSManagedObjectContext) {
        let viewType = photoViewType(visibleMapRect: visibleMapRect)
        if viewType == currentViewType { return }
        self.currentViewType = viewType

        if !loaded {
            if viewType != .nothing { load(context: context) }
        } else {
            for manager in loadedPhotoGeohashes.values {
                manager.update(viewType: viewType)
            }
        }
    }

    func unload() {
        for manager in loadedPhotoGeohashes.values {
            manager.remove()
        }
    }

    let maxImageMapRectWidth: Double = 50000
    let maxCircleMapRectWidth: Double = 1000000
    private func photoViewType(visibleMapRect: MKMapRect) -> PhotoViewType {
        if visibleMapRect.width < maxCircleMapRectWidth {
            if overlaps(mapRect: visibleMapRect) {
                if visibleMapRect.width < maxImageMapRectWidth {
                    return .image
                }
                return .circle
            }
        }
        return .nothing
    }

    private func fetchAssetsFor(photos: [Photo]) -> PHFetchResult<PHAsset> {
        let localIdentifiers = photos.map({ $0.localIdentifier }).filter({ $0 != nil }).map({ $0! })
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers,
                                         options: PHFetchOptions())

        return assets
    }

    private func overlaps(mapRect: MKMapRect) -> Bool {
        let lowLeft = MKCoordinateForMapPoint(MKMapPoint(x: mapRect.minX, y: mapRect.minY))
        let topRight = MKCoordinateForMapPoint(MKMapPoint(x: mapRect.maxX, y: mapRect.maxY))
        let mapMinLatitude = min(lowLeft.latitude, topRight.latitude)
        let mapMaxLatitude = max(lowLeft.latitude, topRight.latitude)
        let mapMinLongitude = min(lowLeft.longitude, topRight.longitude)
        let mapMaxLongitude = max(lowLeft.longitude, topRight.longitude)

        let noOverlap = mapMinLatitude > latitude.max ||
            latitude.min > mapMaxLatitude ||
            mapMinLongitude > longitude.max ||
            longitude.min > mapMaxLongitude

        return !noOverlap
    }

    private func load(context: NSManagedObjectContext) {
        loaded = true

        DispatchQueue.global(qos: .background).async {
            guard let photos = Photo.allWith(geohash: self.geohash,
                                             year: self.year,
                                             cumulative: self.cumulative,
                                             context: context) else {
                                                return
            }
            let assets = self.fetchAssetsFor(photos: photos)

            assets.enumerateObjects { (asset, _, _) in
                if self.currentViewType == .nothing { return }
                guard let location = asset.location?.coordinate else { return }

                let photoGeohash = Geohash.encode(latitude: location.latitude, longitude: location.longitude, precision: .seventySixMeters)

                if self.loadedPhotoGeohashes[photoGeohash] == nil {
                    let manager = PhotoGeohashManager(asset: asset, geohash: photoGeohash, mapView: self.mapView)
                    manager.update(viewType: self.currentViewType)
                    self.loadedPhotoGeohashes[photoGeohash] = manager
                }
            }
        }
    }
}

class PhotoMapViewer {
    
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var context: NSManagedObjectContext
    var year: Year?
    var cumulative: Bool?
    var loadedGeohashes: [String: LargerGeohashManager] = [:]
    var active = true

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, context: NSManagedObjectContext) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.context = context
    }

    func unload() {
        active = false
        removeFromMap()
    }

    func removeFromMap() {
        for manager in loadedGeohashes.values {
            manager.unload()
        }
        loadedGeohashes.removeAll()
    }

    func load(year: Year, cumulative: Bool) {
        self.active = true
        self.year = year
        self.cumulative = cumulative

        guard let geohashes = year.geohashes(cumulative: cumulative) else { return }
        for geohash in geohashes {
            let manager = LargerGeohashManager(geohash: geohash, mapView: self.mapView, year: year.year, cumulative: cumulative)
            self.loadedGeohashes[geohash] = manager
        }
    }

    func viewChanged(visibleMapRect: MKMapRect) {
        for manager in self.loadedGeohashes.values {
            manager.viewChanged(visibleMapRect: visibleMapRect, context: self.context)
        }
    }

}
