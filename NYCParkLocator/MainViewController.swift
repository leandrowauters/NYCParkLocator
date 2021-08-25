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
    
    var properties = [Properties]() {
        didSet {
            print("DID SET: \(properties.count)")
        }
    }
    
    var selectedOverlay: MKOverlay?
    var selectedLocation: Properties?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        requestLocationPersmissions()
        setupMapView()
    }

    private func requestLocationPersmissions() {
      locationManager.requestWhenInUseAuthorization()
    }
    
    func filterPropertiesByCategory(category: String) -> [Properties] {
        return properties.filter{$0.typecatego == category}
    }
    private func userLocationButtonHandler() {
        //TODO: SHOW ALERT WHEN DENIED. SHOW USER LOCATION WHEN APPROVED
        

        switch locationManager.authorizationStatus {
        case .authorizedAlways:
          print("authorizedAlways")
            guard let userCoordinate = self.userCoordinate else {
                return
            }
          centerMap(coordinate: userCoordinate)
        case .authorizedWhenInUse:
          print("authorizedWhenInUse")
            guard let userCoordinate = self.userCoordinate else {
                return
            }
          centerMap(coordinate: userCoordinate)
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
        Park.parseGeoJSON { [self] overlays, properties in
            self.properties = properties
            //        mapView.addOverlays(overlays)
            self.mapView.addAnnotations(overlays)
                    // Map Customization:
            self.mapView.isRotateEnabled = false
            self.mapView.showsCompass = false
                    
            //        mapView.showsBuildings = false
            self.mapView.pointOfInterestFilter = .init(including: [.park])
        }

    }
    
    private func showAppSettings() {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        
    }
    

    @IBAction func didPressMyLocation(_ sender: Any) {
        userLocationButtonHandler()
    }
    
    func centerMap(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        //MARK: THIS SHOULD BE CHECK!
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
          centerMap(coordinate: defultCoordinate)
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
        centerMap(coordinate: userCoordinate)
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
        
        if let selectedOverlay = selectedOverlay {
            mapView.removeOverlay(selectedOverlay)
        }
        guard let annotation = view.annotation else {
            return 
        }
        let overlay = view.annotation as? MKOverlay
        let selectedProperties = properties.filter {$0.signname == annotation.title}
        if let selectedProperties = selectedProperties.first {
            print(selectedProperties.name311 ?? "N/A")
            self.selectedLocation = selectedProperties
        }
        self.selectedOverlay = overlay
        centerMap(coordinate: annotation.coordinate)
        mapView.addOverlay(overlay!)
    }
    
    
}
