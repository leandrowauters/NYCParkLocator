////
////  Park.swift
////  NYCParkLocator
////
////  Created by Leandro Wauters on 8/24/21.
////
//
import Foundation
import CoreLocation
import MapKit


struct Park: Codable {
    let type: String
    let features: [Feature]
    
    
    static let parksTypesToFilter = ["Nature Area", "Recreation Field/Courts", "Neighborhood Park", "Community Park", "Garden", "Triangle/Plaza", "Playground", "Flagship Park", "Waterfront Facility"]
    
    static func loadParksFromJSON(completion: @escaping([Properties]?, String?) -> Void)  {
        Bundle.main.decode(Park.self, from: "parkGeoJson.json") { park, error in
            
            var properties = [Properties]()
            
            if let error = error {
                completion(nil, error)
            }
            
            if let park = park {
                let filtered = park.features.filter { feature in
                    
                    return parksTypesToFilter.contains(feature.properties.typecatego ?? "N/A")
                }
                

                for feature in filtered {
                    
                    properties.append(feature.properties)
                }
                completion(properties, nil)
            }
        }
    }
    
    static func parseGeoJSON() -> [MKOverlay] {
        guard let url = Bundle.main.url(forResource: "parkGeoJson", withExtension: "json") else {
            fatalError("Undable to get geojson")
        }
        var geoJson = [MKGeoJSONObject]()
        do {
            let data = try Data(contentsOf: url)
            geoJson = try MKGeoJSONDecoder().decode(data)
        } catch {
            fatalError("Unable to decode geojson")
        }
        var overlays = [MKOverlay]()
        for item in geoJson {
            if let feature = item as? MKGeoJSONFeature {
                do {
                    
                    let property = try JSONDecoder().decode(Properties.self, from: feature.properties!)
                    if parksTypesToFilter.contains(property.typecatego ?? "N/A") {
                        for geo in feature.geometry {
                            if let polygon = geo as? MKMultiPolygon {
                                polygon.title = property.name311
                                overlays.append(polygon)
                            }
                        }
                    }
                    
                } catch {
                    fatalError("Unable to decode geojson")
                }

            }
        }
        print("returning: \(overlays.count) overlays")
        return overlays
    }

}

// MARK: - Feature
struct Feature: Codable {
    let type: FeatureType
    let properties: Properties
    let geometry: Geometry
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: GeometryType
    let coordinates: [[[[Double]]]]
}

enum GeometryType: String, Codable {
    case multiPolygon = "MultiPolygon"
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}

struct Properties: Codable {
    var usCongres, mapped, globalID, zipcode: String?
    var acres, location, typecatego, commission: String?
    var url: String?
    var permitpare, eapply, parentid, gispropnum: String?
    var acquisitio, retired, subcategor, jurisdicti: String?
    var objectid, communityb, name311, permitdist: String?
    var pipRatabl, department, precinct, permit: String?
    var omppropid, gisobjid, signname, address: String?
    var nysAssemb, propretiesClass, nysSenate, councildis: String?
    var borough, waterfront: String?

    enum CodingKeys: String, CodingKey {
        case usCongres = "us_congres"
        case mapped
        case globalID = "global_id"
        case zipcode, acres, location, typecatego, commission, url, permitpare, eapply, parentid, gispropnum, acquisitio, retired, subcategor, jurisdicti, objectid, communityb, name311, permitdist
        case pipRatabl = "pip_ratabl"
        case department, precinct, permit, omppropid, gisobjid, signname, address
        case nysAssemb = "nys_assemb"
        case propretiesClass = "class"
        case nysSenate = "nys_senate"
        case councildis, borough, waterfront
    }
}
//
//struct Park: Codable {
//    var name311: String
//    var location: String
//    var url: String?
//    var zipcode: String
//    var multipolygon: Multipolygon
//
//    var address: String {
//        return location + ", " + zipcode
//    }
//
//
////    var coordinate: CLLocationCoordinate2D
////
////    static func getCoordinateFromAddress(address: String, completion: @escaping(CLLocationCoordinate2D?, Error?) -> Void) {
////        let geocoder = CLGeocoder()
////
////        geocoder.geocodeAddressString(address) { placemarks, error in
////            if let error = error {
////                completion(nil, error)
////            }
////            if let placemarks = placemarks {
////                completion(placemarks.first?.location?.coordinate, nil)
////            }
////        }
////    }
//
////    private func getCoordinateFromAddress(address: String) -> CLLocationCoordinate2D?{
////        let geocoder = CLGeocoder()
////        var coordinate: CLLocationCoordinate2D?
////        geocoder.geocodeAddressString(address) { placemarks, error in
////            if let error = error {
////                coordinate = nil
////                print(error.localizedDescription)
////            }
////            if let placemarks = placemarks {
////                coordinate = placemarks.first?.location?.coordinate
////            }
////        }
////        return coordinate
////    }

//
//struct Multipolygon: Codable {
//    let type: String
//    let coordinates: [[[[Double]]]]
//}
