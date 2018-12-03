//
//  NavigationViewController.swift
//  testing
//
//  Created by Arti Patankar on 11/15/18.
//  Copyright © 2018 com.example. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NavigationViewController: UIViewController {
    
   
    @IBOutlet weak var navigationView: MKMapView!
    
    var friend_location_latitude : CLLocationDegrees?
    var friend_location_longitude : CLLocationDegrees?
    let locationManager = CLLocationManager()
    //let regionRadius: CLLocationDistance = 100000
    let regionRadius: CLLocationDistance = 100

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.delegate = self
        self.setUpLocationManager()
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 34.070470, longitude: -118.442646)
        // let initialLocation = CLLocation(latitude: friend_location_latitude!, longitude: friend_location_longitude!)
        
        centerMapOnLocation(location: initialLocation)

    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        navigationView.setRegion(coordinateRegion, animated: true)
        let endPin = MKPointAnnotation()
        endPin.coordinate = location.coordinate
        endPin.title = "Moore Hall"
        navigationView.addAnnotation(endPin)
        
    }


    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
}

extension NavigationViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //        let selectedAnnotation = view.annotation as? MKPointAnnotation
        //        let building_coordinates = selectedAnnotation?.coordinate
        //        print(building_coordinates)
        //        let qs = QueryService()
        //  transition to 
        print("clicked")
    }
}

extension NavigationViewController: CLLocationManagerDelegate {}


