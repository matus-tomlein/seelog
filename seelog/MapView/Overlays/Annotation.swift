//
//  Annotation.swift
//  seelog
//
//  Created by Matus Tomlein on 22/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import MapKit

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
