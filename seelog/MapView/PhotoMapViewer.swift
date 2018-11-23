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

class PhotoGeohashManager {
    var asset: PHAsset
    var geohash: String
    var mapView: MKMapView
    var circleOverlay: MapCircle?
    var polylineOverlay: MapPolyline?
    var imageOverlay: ImageOverlay?
    var showingImage = false
    var showingCircle = false
    var location: CLLocationCoordinate2D
    var currentViewPort: CurrentViewport
    var overlayVersion: Int

    init(asset: PHAsset, geohash: String, mapView: MKMapView, currentViewPort: CurrentViewport, overlayVersion: Int) {
        self.asset = asset
        self.geohash = geohash
        self.mapView = mapView
        self.location = CLLocationCoordinate2D(geohash: geohash)
        self.currentViewPort = currentViewPort
        self.overlayVersion = overlayVersion
    }

    func update() {
        let viewType = currentViewPort.photoViewType(geohash: geohash)
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
        DispatchQueue.main.async {
            if self.showingCircle { self.removeCircle() }
            if self.showingImage { self.removeImage() }
        }
    }

    private func showAsCircle() {
        if showingCircle { return }
        showingCircle = true

        DispatchQueue.main.async {
            self.removeImage()
            if let circleOverlay = self.circleOverlay { self.mapView.remove(circleOverlay) }
            self.circleOverlay = GeometryOverlayCreator.addCircleToMap(center: self.location,
                                                                       radius: 1,
                                                                       properties: MapOverlayProperties(self.overlayVersion),
                                                                       mapView: self.mapView)
        }
    }

    var openImageRequestID: PHImageRequestID?
    private func showAsImage() {
        if showingImage { return }
        showingImage = true
        if openImageRequestID != nil { return }

        let imageManager = PHImageManager.default()
        openImageRequestID = imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 1280, height: 1280),
                                  contentMode: .aspectFit, options: nil,
                                  resultHandler: { (image, info) in
                                    if let image = image {
                                        DispatchQueue.main.async {
                                            if self.currentViewPort.photoViewType(geohash: self.geohash) == .image {
                                                self.removeCircle()
                                                self.addImage(image: image)
                                            } else {
                                                self.showingImage = false
                                            }
                                        }
                                    }
        })
    }

    private func removeImage() {
        showingImage = false

        if let openImageRequestID = self.openImageRequestID {
            PHImageManager.default().cancelImageRequest(openImageRequestID)
        }
        openImageRequestID = nil

        if let polylineOverlay = self.polylineOverlay { self.mapView.remove(polylineOverlay) }
        if let imageOverlay = self.imageOverlay {
            self.mapView.remove(imageOverlay)
            imageOverlay.image = nil
        }
        self.polylineOverlay = nil
        self.imageOverlay = nil
    }

    private func removeCircle() {
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

        let rect = MKMapRect(origin: MKMapPointForCoordinate(self.location),
                             size: MKMapSize(width: Double(image.size.width) * multiplyBy, height: Double(image.size.height) * multiplyBy))

        if self.polylineOverlay == nil {
            let polylineOverlay = MapPolyline(rect: rect)
            let properties = MapOverlayProperties(self.overlayVersion)
            properties.lineWidth = 3
            polylineOverlay.properties = properties
            mapView.add(polylineOverlay)
            self.polylineOverlay = polylineOverlay
        }

        if let imageOverlay = GeometryOverlayCreator.addImageToMap(image: image,
                                                                   mapView: mapView,
                                                                   rect: rect,
                                                                   overlayVersion: overlayVersion) {
            self.imageOverlay = imageOverlay
        }
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
    var loaded = false
    var year: Int32
    var cumulative: Bool
    var currentViewport: CurrentViewport
    var overlayVersion: Int

    init(geohash: String, mapView: MKMapView, year: Int32, cumulative: Bool, currentViewPort: CurrentViewport, overlayVersion: Int) {
        self.geohash = geohash
        self.mapView = mapView
        self.year = year
        self.cumulative = cumulative
        self.currentViewport = currentViewPort
        self.overlayVersion = overlayVersion
    }

    func viewChanged(context: NSManagedObjectContext) {
        if !loaded {
            if !currentViewport.shouldShowNothing() && currentViewport.overlaps(geohash: geohash) {
                load(context: context)
            }
        } else {
            for manager in loadedPhotoGeohashes.values {
                manager.update()
            }
        }
    }

    func unload() {
        for manager in loadedPhotoGeohashes.values {
            manager.remove()
        }
    }

    private func fetchAssetsFor(photos: [Photo]) -> PHFetchResult<PHAsset> {
        let localIdentifiers = photos.map({ $0.localIdentifier }).filter({ $0 != nil }).map({ $0! })
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers,
                                         options: PHFetchOptions())

        return assets
    }

    private func load(context mainContext: NSManagedObjectContext) {
        loaded = true

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.perform {
            guard let photos = Photo.allWith(geohash: self.geohash,
                                             year: self.year,
                                             cumulative: self.cumulative,
                                             context: context) else {
                                                return
            }
            let assets = self.fetchAssetsFor(photos: photos)

            assets.enumerateObjects { (asset, _, _) in
                guard let location = asset.location?.coordinate else { return }

                let photoGeohash = Geohash.encode(latitude: location.latitude, longitude: location.longitude, precision: .seventySixMeters)

                if self.loadedPhotoGeohashes[photoGeohash] == nil {
                    let manager = PhotoGeohashManager(asset: asset,
                                                      geohash: photoGeohash,
                                                      mapView: self.mapView,
                                                      currentViewPort: self.currentViewport,
                                                      overlayVersion: self.overlayVersion)
                    manager.update()
                    self.loadedPhotoGeohashes[photoGeohash] = manager
                }
            }
        }
    }
}

class CurrentViewport {
    var visibleMapRect: MKMapRect

    init(visibleMapRect: MKMapRect) {
        self.visibleMapRect = visibleMapRect
    }

    let maxImageMapRectWidth: Double = 20000
    let maxCircleMapRectWidth: Double = 1000000
    func photoViewType(geohash: String) -> PhotoViewType {
        if shouldShowNothing() { return .nothing }

        if overlaps(geohash: geohash) {
            if visibleMapRect.width < maxImageMapRectWidth {
                return .image
            }
            return .circle
        }
        return .nothing
    }

    func shouldShowNothing() -> Bool {
        return visibleMapRect.width > maxCircleMapRectWidth
    }

    func overlaps(geohash: String) -> Bool {
        let lowLeft = MKCoordinateForMapPoint(MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY))
        let topRight = MKCoordinateForMapPoint(MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY))
        let mapMinLatitude = min(lowLeft.latitude, topRight.latitude)
        let mapMaxLatitude = max(lowLeft.latitude, topRight.latitude)
        let mapMinLongitude = min(lowLeft.longitude, topRight.longitude)
        let mapMaxLongitude = max(lowLeft.longitude, topRight.longitude)
        let (latitude, longitude) = Geohash.decode(hash: geohash) ?? ((min: 0, max: 0), (min: 0, max: 0))

        let noOverlap = mapMinLatitude > latitude.max ||
            latitude.min > mapMaxLatitude ||
            mapMinLongitude > longitude.max ||
            longitude.min > mapMaxLongitude

        return !noOverlap
    }
}

class PhotoMapViewer {
    
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var context: NSManagedObjectContext
    var year: Year?
    var cumulative: Bool?
    var loadedGeohashes: [String: LargerGeohashManager] = [:]
    var currentViewPort: CurrentViewport
    var updateQueue = BlockingQueue<Date>()

    init(mapView: MKMapView, mapViewDelegate: MainMapViewDelegate, context: NSManagedObjectContext) {
        self.mapView = mapView
        self.mapViewDelegate = mapViewDelegate
        self.context = context
        self.currentViewPort = CurrentViewport(visibleMapRect: mapView.visibleMapRect)
    }

    func unload() {
        removeFromMap()
        updateQueue.add(Date())
    }

    func removeFromMap() {
        for manager in loadedGeohashes.values {
            manager.unload()
        }
        loadedGeohashes.removeAll()
    }

    func load(year: Year, cumulative: Bool) {
        self.year = year
        self.cumulative = cumulative
        let overlayVersion = GeometryOverlayCreator.overlayVersion

        guard let geohashes = year.geohashes(cumulative: cumulative) else { return }
        for geohash in geohashes {
            let manager = LargerGeohashManager(geohash: geohash,
                                               mapView: self.mapView,
                                               year: year.year,
                                               cumulative: cumulative,
                                               currentViewPort: currentViewPort,
                                               overlayVersion: overlayVersion)
            self.loadedGeohashes[geohash] = manager
        }

        startWaitingForUpdates(overlayVersion: overlayVersion)
    }

    func viewChanged(visibleMapRect: MKMapRect) {
        currentViewPort.visibleMapRect = visibleMapRect
        updateQueue.add(Date())
    }

    private func startWaitingForUpdates(overlayVersion: Int) {
        DispatchQueue.global(qos: .background).async {
            while true {
                let date = self.updateQueue.take()
                if overlayVersion < GeometryOverlayCreator.overlayVersion { return }

                if Date().timeIntervalSince(date) < 1 {
                    for manager in self.loadedGeohashes.values {
                        manager.viewChanged(context: self.context)
                    }
                }
            }
        }
    }

}
