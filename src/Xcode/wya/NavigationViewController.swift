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
    var indoorLocationPoint = CGPoint()
    var indoorLocation : [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.delegate = self
        self.setUpLocationManager()
        
        
        self.qs.lookup(friend_email: friend_email) { response in
            if response != nil {
                let location = response!["location"] as! [String:Any]
                let outdoor = location["outdoor_location"] as? [String:Double]
                self.indoorLocation = location["indoor_location"] as? [String:Any]
                
                if outdoor != nil {
                    self.outdoorLocation.longitude = outdoor!["longitude"]!
                    self.outdoorLocation.latitude = outdoor!["latitude"]!
                    self.centerMapOnLocation(location: self.outdoorLocation)
                }
                
                if self.indoorLocation != nil {
                    self.indoorLocationPoint = CGPoint(x: (self.indoorLocation!["x"] as! Double), y: (self.indoorLocation!["y"] as! Double))
                    self.indoorAvailable = true
                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewIndoor(_:)))
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
        if segue.identifier ==  "viewIndoor"
        {
            let vc = segue.destination as! ViewIndoorLocationController
            let il = self.indoorLocation!
            print( il["building"]as! String)
            print(il["floor"]as! String)
            qs.getFloorImage(building_name: il["building"] as! String, floor: il["floor"] as! String) { response in
                guard let image = response else {
                    print("Did not get image")
                    return
                }
                vc.image = image
            }
            vc.indoorLocationPoint = self.indoorLocationPoint
        }
    }
    
    @objc func showIndoor(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended && self.indoorAvailable {
            self.performSegue(withIdentifier: "viewIndoor", sender: self)
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


