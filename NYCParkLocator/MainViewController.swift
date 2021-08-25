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
        
        requestLocationPersmissions()
        setupMapView()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        loadParks { parks, error in
//
//        }
//    }

    private func loadParks(completion: @escaping([Properties]?, String?) -> Void) {
        var parks = [Park]()
        Park.loadParksFromJSON { properties, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let properties = properties {
                print("properties found: \(properties.count)")
                var parkProperties = [String]()
                for property in properties {
                    parkProperties.append(property.typecatego ?? "N/A")
                    
                }
                print(Set(parkProperties))
            }
        }
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
        mapView.delegate = self
        mapView.showsUserLocation = true
        let overlays = Park.parseGeoJSON()
//        mapView.addOverlays(overlays)
        mapView.addAnnotations(overlays)
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view)
    }
    
}


