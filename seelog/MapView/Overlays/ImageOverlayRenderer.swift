//
//  ImageOverlayRenderer.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

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
