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

    let image:UIImage
    let boundingMapRect: MKMapRect
    let coordinate:CLLocationCoordinate2D

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

        UIGraphicsPushContext(context)
        overlay.image.draw(in: rect)
        UIGraphicsPopContext()
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

class PhotoMapViewer {
    
    var mapView: MKMapView
    var mapViewDelegate: MainMapViewDelegate
    var context: NSManagedObjectContext
    var year: Year?
    var cumulative: Bool?
    var loadedGeohashes = Set<String>()
    var loadedPhotoGeohashes = Set<String>()
    var overlays: [MKOverlay] = []
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
        mapView.removeOverlays(overlays)
        overlays.removeAll()
        loadedGeohashes.removeAll()
        loadedPhotoGeohashes.removeAll()
    }

    func load(year: Year, cumulative: Bool) {
        self.active = true
        self.year = year
        self.cumulative = cumulative

        self.viewChanged(visibleMapRect: mapView.visibleMapRect)
    }

    let maxMapRectWidth: Double = 250000
    func viewChanged(visibleMapRect: MKMapRect) {
        if visibleMapRect.width > maxMapRectWidth {
            removeFromMap()
            return
        }

        guard let year = self.year, let cumulative = self.cumulative else { return }

        DispatchQueue.global(qos: .background).async {
            var geohashes = Helpers.geohashesIn(mapRect: visibleMapRect)
            geohashes = geohashes.filter({ !self.loadedGeohashes.contains($0) })
            for geohash in geohashes { self.loadedGeohashes.insert(geohash) }

            guard let photos = Photo.allWith(geohashes: Array(geohashes),
                                             year: year.year,
                                             cumulative: cumulative,
                                             context: self.context) else {
                return
            }
            let assets = self.fetchAssetsFor(photos: photos)
            let imageManager = PHImageManager.default()

            for asset in assets {
                guard let location = asset.location?.coordinate else { continue }

                let photoGeohash = Geohash.encode(latitude: location.latitude, longitude: location.longitude, precision: .seventySixMeters)

                if self.loadedPhotoGeohashes.contains(photoGeohash) { continue }
                self.loadedPhotoGeohashes.insert(photoGeohash)

                imageManager.requestImage(for: asset,
                                          targetSize: CGSize(width: 640, height: 640),
                                          contentMode: .aspectFit, options: nil,
                                          resultHandler: { (image, info) in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.addImage(image: image, photoGeohash: photoGeohash)
                        }
                    }
                })
            }
        }
    }

    private func fetchAssetsFor(photos: [Photo]) -> [PHAsset] {
        let localIdentifiers = photos.map({ $0.localIdentifier }).filter({ $0 != nil }).map({ $0! })
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers,
                                         options: PHFetchOptions())

        var assetsArray: [PHAsset] = []
        assets.enumerateObjects { (asset, _, _) in
            assetsArray.append(asset)
        }
        return assetsArray
    }

    private func addImage(image: UIImage, photoGeohash: String) {
        if mapView.visibleMapRect.width > maxMapRectWidth || !active { return }

        let multiplyBy = 640 / ([Double(image.size.width), Double(image.size.height)].max() ?? 0)

        let rect = MKMapRect(origin: MKMapPointForCoordinate(CLLocationCoordinate2D(geohash: photoGeohash)),
                             size: MKMapSize(width: Double(image.size.width) * multiplyBy, height: Double(image.size.height) * multiplyBy))

        let polyline = ImageBorderPolyline(rect: rect)
        self.mapView.add(polyline)
        overlays.append(polyline)

        let overlay = ImageOverlay(image: image,
                                   rect: rect)
        self.mapView.add(overlay)
        overlays.append(overlay)
    }
}
