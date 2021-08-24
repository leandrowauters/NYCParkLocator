//
//  MainViewController.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/20/21.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    
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
    
    override func viewDidAppear(_ animated: Bool) {
        loadParks()
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
}


