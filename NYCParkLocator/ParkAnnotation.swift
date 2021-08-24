//
//  ParkAnnotation.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/24/21.
//

import MapKit
import CoreLocation

class ParkAnnotation:  NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String?

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
