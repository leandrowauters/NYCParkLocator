//
//  Park.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/24/21.
//

import Foundation
import CoreLocation
import MapKit

struct Park: Codable {
    var name311: String
    var location: String
    var url: String?
    var zipcode: String
    var multipolygon: Multipolygon
    
    var address: String {
        return location + ", " + zipcode
    }
    
    func test() {
//        MKMultiPolygon.init(<#T##polygons: [MKPolygon]##[MKPolygon]#>)
        MKPolygon.init(coordinates: <#T##UnsafePointer<CLLocationCoordinate2D>#>, count: <#T##Int#>)
    }
//    var coordinate: CLLocationCoordinate2D
//    
//    static func getCoordinateFromAddress(address: String, completion: @escaping(CLLocationCoordinate2D?, Error?) -> Void) {
//        let geocoder = CLGeocoder()
//
//        geocoder.geocodeAddressString(address) { placemarks, error in
//            if let error = error {
//                completion(nil, error)
//            }
//            if let placemarks = placemarks {
//                completion(placemarks.first?.location?.coordinate, nil)
//            }
//        }
//    }
    
//    private func getCoordinateFromAddress(address: String) -> CLLocationCoordinate2D?{
//        let geocoder = CLGeocoder()
//        var coordinate: CLLocationCoordinate2D?
//        geocoder.geocodeAddressString(address) { placemarks, error in
//            if let error = error {
//                coordinate = nil
//                print(error.localizedDescription)
//            }
//            if let placemarks = placemarks {
//                coordinate = placemarks.first?.location?.coordinate
//            }
//        }
//        return coordinate
//    }
    static func loadParksFromJSON(completion: @escaping([Park]?, String?) -> Void)  {
        Bundle.main.decode([Park].self, from: "ParksJSON.json") { parks, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let parks = parks {
                completion(parks, nil)
            }
        }
    }
    
    
}

struct Multipolygon: Codable {
    let type: String
    let coordinates: [[[[Double]]]]
}
