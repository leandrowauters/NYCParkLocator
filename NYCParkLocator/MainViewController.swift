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
    @IBOutlet weak var filterButton: UIButton!
    
    
    private var locationManager = CLLocationManager()
    
    private var userCoordinate: CLLocationCoordinate2D?
    let defultCoordinate = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)
    
    let regionRadius: Double = 1500
    private var filters = [String]()
    var properties = [Properties]()
    var annotations = [MKAnnotation]()
    var selectedOverlay: MKOverlay?
    var selectedLocation: Properties?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        requestLocationPersmissions()
        setupFilters()
        setupMapView()
        
    }
    
    
    private func setupFilters() {
        filters = UserDefaultsHelper.loadFilterCategories()
        print("CATEGORIES TO FILTER \(filters)")
        if !filters.isEmpty {
            filterButton.addCount(count: filters.count)
//            //MARK: TODO: APPLY FILTERS
//            self.properties = filterProperties(properties: properties, categories: filters)
        }
    }
    
    private func filterProperties(properties: [Properties], categories: [String]) -> [Properties] {
        
        if categories.isEmpty {
            return properties
        }
        var propertiesToReturn = [Properties]()
        for property in properties {
            let type = property.typecatego ?? String()
            if categories.contains(type) {
                propertiesToReturn.append(property)
            }
        }
        print("Total Properties: \(properties.count), Filtered: \(propertiesToReturn.count)")
        return propertiesToReturn
    }
    private func requestLocationPersmissions() {
      locationManager.requestWhenInUseAuthorization()
    }
    
//    func filterPropertiesByCategory(category: String) -> [Properties] {
//        return properties.filter{$0.typecatego == category}
//    }
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
        
        Park.parseGeoJSON(categoryFilters: filters) { [self] overlays, properties in
            
           
                mapView.removeAnnotations(self.annotations)
            
            
      
            self.properties = properties
            self.annotations = overlays
            print("PROPERTIES AFTER LOADED: \(self.properties.count)")
            print("OVERLAY AFTER LOADING \(self.annotations.count)")
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
//        let filterVC = FilterViewController()
//        filterVC.filterDelegate = self
//        present(filterVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as?  FilterViewController else {
            return
        }
        destination.filterDelegate = self
        destination.selectedCategories = filters
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

extension MainViewController: FilterDelegate {
    
    func didSelectCategories() {
        filters = UserDefaultsHelper.loadFilterCategories()
        setupMapView()
        if filters.isEmpty {
            filterButton.removeCount()
        } else {
            filterButton.addCount(count: filters.count)
        }
        for filter in filters {
            print(filter)
        }
    }
}
