//
//  MainViewController.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/20/21.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    private var locationManager = CLLocationManager()
    
    private var userCoordinate: CLLocationCoordinate2D?
    let defultCoordinate = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)
    
    let regionRadius: Double = 1500
    
   var parks = [Park]() {
        didSet {
            print("DID SET")
         
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        requestLocationPersmissions()
        setupMapView()
    }
    

    private func loadParks() {
        Park.loadParksFromJSON { parks, error in
            if let error = error {
                self.showAlert(title: "Error loading data", message: error)
            }
            
            if let parks = parks {
                print("PARKS FOUND: \(parks.count)")
                print("PARK Address: \(parks.first!.address)")
                print("Multi: \(parks.first!.multipolygon)")
                
                self.parks = parks
                
            }
        }
    }
    

    func parseGeoJSON() -> [MKOverlay] {
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
                for geo in feature.geometry {
                    if let polygon = geo as? MKMultiPolygon {
                        overlays.append(polygon)
                    }
                }
            }
        }
        print("returning: \(overlays.count) overlays")
        return overlays
    }

    
    private func requestLocationPersmissions() {
      locationManager.requestWhenInUseAuthorization()
    }
    
    private func userLocationButtonHandler() {
        //TODO: SHOW ALERT WHEN DENIED. SHOW USER LOCATION WHEN APPROVED
        

        switch locationManager.authorizationStatus {
        case .authorizedAlways:
          print("authorizedAlways")
            guard let userCoordinate = self.userCoordinate else {
                return
            }
          centerMapOnUserLocation(coordinate: userCoordinate)
        case .authorizedWhenInUse:
          print("authorizedWhenInUse")
            guard let userCoordinate = self.userCoordinate else {
                return
            }
          centerMapOnUserLocation(coordinate: userCoordinate)
        case .denied, .notDetermined, .restricted:
          print("denied")
            showAlert(title: "User Location Status: Denied", message: "Open Settings?") { alertAction in
                self.showAppSettings()
            }
        default:
          break
        }
    }
    private func setupMapView() {
        
        mapView.showsUserLocation = true
        mapView.addOverlays(self.parseGeoJSON())
    }
    
    private func showAppSettings() {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    

    @IBAction func didPressMyLocation(_ sender: Any) {
        userLocationButtonHandler()
    }
    
    func centerMapOnUserLocation(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .authorizedAlways:
          print("authorizedAlways")
          locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
          print("authorizedWhenInUse")
          locationManager.startUpdatingLocation()
        case .denied, .notDetermined, .restricted:
          print("denied")
            

            centerMapOnUserLocation(coordinate: defultCoordinate)
        default:
          break
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        userCoordinate = currentLocation.coordinate
        guard let userCoordinate = self.userCoordinate else {
            print("NO USER COORDINATE FOUNT")
            return
        }
        centerMapOnUserLocation(coordinate: userCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

      if let multiPolygon = overlay as? MKMultiPolygon {
        let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
        let renderingColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        renderer.fillColor = renderingColor.withAlphaComponent(0.5)
        renderer.strokeColor = renderingColor
        renderer.lineWidth = 0.5
        return renderer
      }



      return MKOverlayRenderer(overlay: overlay)

    }
}


