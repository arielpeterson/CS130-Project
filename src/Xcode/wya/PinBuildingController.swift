//
//  PinBuildingController.swift
//  wya
//
//  Created by Arti Patankar on 12/2/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PinBuildingController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let newPin = MKPointAnnotation()
    
    let range : Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(pinLocation(_:)))
        mapView.addGestureRecognizer(hold)
    }
    
    @objc func pinLocation(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let holdLocation = sender.location(in: mapView)
            let holdCoordinate = mapView.convert(holdLocation, toCoordinateFrom: mapView)
            newPin.coordinate = holdCoordinate
            mapView.addAnnotation(newPin)
        }
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerView() {
        if let location = locationManager.location?.coordinate {
            // center is user's location, set bounds
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: range, longitudinalMeters: range)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerView()
            locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}
