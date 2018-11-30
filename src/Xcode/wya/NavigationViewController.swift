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
    
    var destination = CLLocationCoordinate2D()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationView.delegate = self
        navigationView.showsPointsOfInterest = true
        navigationView.showsUserLocation = true
        setUpLocationManager()
        generateDirections()
    }
    
    // without this, the overlay is not visible
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.gray
        renderer.lineWidth = 5
        
        return renderer
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func generateDirections() {
        locationManager.startUpdatingLocation()
        
        let location = locationManager.location?.coordinate
        //let destination = CLLocationCoordinate2DMake(34.0688, -118.4440)
        
        let start = MKPlacemark(coordinate: location!)
        let end = MKPlacemark(coordinate: destination)

        let startItem = MKMapItem(placemark: start)
        let endItem = MKMapItem(placemark: end)

        let endPin = MKPointAnnotation()
        endPin.coordinate = destination
        endPin.title = "X"
        navigationView.addAnnotation(endPin)

        
        let request = MKDirections.Request()
        request.source = startItem
        request.destination = endItem
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else {
                return
            }
            
            let route = response.routes[0]
            self.navigationView.addOverlay(route.polyline, level: .aboveRoads)
            
            let region = route.polyline.boundingMapRect
            self.navigationView.setRegion(MKCoordinateRegion(region), animated: true)
        })
    }
}

extension NavigationViewController: MKMapViewDelegate {}

extension NavigationViewController: CLLocationManagerDelegate {}
