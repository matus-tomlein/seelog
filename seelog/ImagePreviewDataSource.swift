//
//  ImagePreviewController.swift
//  seelog
//
//  Created by Matus Tomlein on 27/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import QuickLook
import Photos
import CoreData
import MapKit

class PreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?
}

class ImagePreviewDataSource: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    var assets: [PHAsset]
    var items: [Int: PreviewItem] = [:]
    var requests: [PHImageRequestID] = []
    let imageManager = PHImageManager.default()
    private var imagesToLoad: [Int: (UIImage, PHAsset)] = [:]
    private var newImagesLoaded = BlockingQueue<Bool>()
    private var active = true
    private weak var reportViewController: ReportViewController?

    init(assets: [PHAsset], reportViewController: ReportViewController) {
        self.assets = assets
        self.reportViewController = reportViewController
    }

    func load() {
        let alert = UIAlertController(title: "Loading", message: "Fetching images.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dismiss()
        }))
        reportViewController?.present(alert, animated: true, completion: nil)

        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        quickLookController.delegate = self

        var shown = false

        DispatchQueue.global(qos: .background).async {
            while self.active {
                let _ = self.newImagesLoaded.take()
                if !self.active { return }

                let imagesToLoad = self.imagesToLoad
                self.imagesToLoad = [:]
                for index in Array(imagesToLoad.keys) {
                    guard let (image, asset) = imagesToLoad[index] else { continue }

                    self.saveToDisk(asset: asset,
                                    image: image,
                                    controller: quickLookController,
                                    index: index)
                }

                DispatchQueue.main.sync {
                    if !shown {
                        shown = true
                        alert.dismiss(animated: true, completion: {
                            self.reportViewController?.present(quickLookController, animated: true, completion: nil)
                        })
                    } else {
                        quickLookController.reloadData()
                    }
                }
            }
        }

        for i in 0..<assets.count {
            let asset = assets[i]

            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: 600 * scale, height: 600 * scale)

            let id = imageManager.requestImage(for: asset,
                                      targetSize: targetSize,
                                      contentMode: .aspectFit, options: options,
                                      resultHandler: { (image, info) in
                                        if let image = image {
                                            self.imagesToLoad[i] = (image, asset)
                                            self.newImagesLoaded.add(true)
                                        }
            })
            requests.append(id)
        }
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return Array(items.values)[index]
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        dismiss()
        DispatchQueue.main.async {
            if let mapView = self.reportViewController?.mapView {
                mapView.setCenter(mapView.centerCoordinate, animated: true)
            }
        }
    }

    func dismiss() {
        active = false
        for requestId in requests {
            imageManager.cancelImageRequest(requestId)
        }
        items.removeAll()
        assets.removeAll()
        imagesToLoad.removeAll()
        newImagesLoaded.add(true)
    }

    private func saveToDisk(asset: PHAsset, image: UIImage, controller: QLPreviewController, index: Int) {
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }

        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL = tempDirectoryURL.appendingPathComponent("photo-\(index).jpg")
        try? data.write(to: targetURL)

        let item = PreviewItem()
        item.previewItemURL = targetURL
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if let date = asset.creationDate { item.previewItemTitle = formatter.string(from: date) }

        items[index] = item
    }

}
