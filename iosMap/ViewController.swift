//
//  ViewController.swift
//  iosMap
//
//  Created by YU Kaiwen on 26/08/2017.
//  Copyright © 2017 YU Kaiwen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var MapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var latestLocation: CLLocation!
    var ref: DatabaseReference!
    
    var restaurantList = [Restaurant]()
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        
        ref = Database.database().reference()
        MapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        if(CLLocationManager.locationServicesEnabled()) {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ref.observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let restaurants = snapshot.value as? NSDictionary
            
            for restaurant in restaurants! {
                let restaurantKey = restaurant.key as! String
                let restaurantInfo = restaurant.value as AnyObject
                let restaurantAddress = restaurantInfo["address"] as? String ?? ""
                let restaurantLatitude = restaurantInfo["latitude"] as? Double ?? 0
                let restaurantLongitude = restaurantInfo["longitude"] as? Double ?? 0
                
                guard let oneRestaurant = Restaurant(name: restaurantKey, address: restaurantAddress, latitude: restaurantLatitude, longitude: restaurantLongitude) else {
                    fatalError("Unable to instantiate oneRestaurant")
                }
                self.restaurantList.append(oneRestaurant)
                
                let restoLocation = CLLocationCoordinate2D(latitude: oneRestaurant.latitude!, longitude: oneRestaurant.longitude!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = restoLocation
                annotation.title = oneRestaurant.name
                annotation.subtitle = oneRestaurant.address
                self.MapView.addAnnotation(annotation)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // set initial location
        let centerLocation = CLLocationCoordinate2D(latitude: 43.69883919999999,
                                              longitude: 7.26967860000002)
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegion(center: centerLocation, span: span)
        MapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerLocation
        annotation.title = "YKW"
        annotation.subtitle = "Start Location"
        self.MapView.addAnnotation(annotation)

//        startDirection()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
    }
    
    private func startDirection() {
        // 2.
        let destinationLocation = CLLocationCoordinate2D(latitude: 43.300000, longitude: 5.400000)
        let sourceLocation = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        
        // 3.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 4.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 5.
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 6.
        MapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate(){
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.MapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.MapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
}

