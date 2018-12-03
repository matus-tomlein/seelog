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
    var index: Int
    var previewItemURL: URL?
    var previewItemTitle: String?

    init(index: Int) {
        self.index = index
    }
}

class ImagePreviewDataSource: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    var assets: [PHAsset]
    var items: [Int:PreviewItem] = [:]
    var requests: [PHImageRequestID] = []
    let imageManager = PHImageManager.default()
    private var active = true
    private weak var reportViewController: ReportViewController?
    private var shouldUpdateView = false
    private var shown = false

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

        DispatchQueue.global(qos: .background).async {
            sleep(1)
            while self.active {
                if self.shouldUpdateView {
                    DispatchQueue.main.sync {
                        self.shouldUpdateView = false
                        if self.shown {
                            quickLookController.reloadData()
                        } else {
                            self.shown = true
                            alert.dismiss(animated: true, completion: {
                                self.reportViewController?.present(quickLookController, animated: true, completion: nil)
                            })
                        }

                    }
                }
                sleep(3)
            }
        }

        DispatchQueue.global(qos: .background).async {
            for i in 0..<self.assets.count {
                if !self.active { return }
                let asset = self.assets[i]

                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                let scale = UIScreen.main.scale
                let targetSize = CGSize(width: 600 * scale, height: 600 * scale)

                autoreleasepool {
                    let id = PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit, options: options,
                                              resultHandler: { (image, info) in
                                                if !self.active { return }

                                                if let image = image,
                                                    let item = self.saveToDisk(asset: asset,
                                                                               image: image,
                                                                               controller: quickLookController,
                                                                               index: i) {
                                                    self.items[i] = item
                                                    self.shouldUpdateView = true
                                                }
                    })
                    self.requests.append(id)
                }
            }

        }
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return assets.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let item = items[index] { return item }
        let url = Bundle.main.url(forResource: "blank", withExtension: "png")
        return url! as QLPreviewItem
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
        requests.removeAll()
    }

    var fileId = 0
    private func saveToDisk(asset: PHAsset, image: UIImage, controller: QLPreviewController, index: Int) -> PreviewItem? {
        guard let data = UIImageJPEGRepresentation(image, 1) else { return nil }

        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL = tempDirectoryURL.appendingPathComponent("photo-\(index).jpg")
        fileId += 1
        try? data.write(to: targetURL)

        let item = PreviewItem(index: index)
        item.previewItemURL = targetURL
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if let date = asset.creationDate { item.previewItemTitle = formatter.string(from: date) }

        return item
    }

}
