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
    
    let qs = QueryService()
    var friend_email = ""
    let locationManager = CLLocationManager()
    //let regionRadius: CLLocationDistance = 100000
    let regionRadius: CLLocationDistance = 1000
    var outdoorLocation = CLLocationCoordinate2D()
    var indoorAvailable = false
    var indoorLocation = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.delegate = self
        self.setUpLocationManager()
        
        self.qs.lookup(friend_email: friend_email) { response in
            if response != nil {
                let location = response!["location"] as! [String:Any]
                let outdoor = location["outdoor_location"] as? [String:Double]
                let indoor = location["indoor_location"] as? [String:Double]
                
                if outdoor != nil {
                    self.outdoorLocation.longitude = outdoor!["longitude"]!
                    self.outdoorLocation.latitude = outdoor!["latitude"]!
                    self.centerMapOnLocation(location: self.outdoorLocation)
                }
                
                if indoor != nil {
                    self.indoorLocation = CGPoint(x: indoor!["x"]!, y: indoor!["y"]!)
                    self.indoorAvailable = true
                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showIndoor(_:)))
        navigationView.addGestureRecognizer(tap)
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        navigationView.setRegion(coordinateRegion, animated: true)
        let endPin = MKPointAnnotation()
        endPin.coordinate = location
        navigationView.addAnnotation(endPin)
        
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier ==  "showIndoor"
        {
            let vc = segue.destination as! ViewIndoorLocationController
            
            vc.indoorLocation = indoorLocation
        }
    }
    
    @objc func showIndoor(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended && indoorAvailable {
            self.performSegue(withIdentifier: "showIndoor", sender: self)
        }
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


