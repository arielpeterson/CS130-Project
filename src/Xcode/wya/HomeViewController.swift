//
//  MapScreen.swift
//  testing
//
//  Created by Arti Patankar on 11/14/18.
//  Copyright © 2018 com.example. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import GoogleSignIn

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    

    let locationManager = CLLocationManager()
    let range : Double = 1000
    let qs = QueryService()
    var friends : [String] = []
    var selected_friend : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "customcell")
        checkLocationServices()

        qs.getFriends() { response in
            guard let friendList = response else {
                print("No friends! :(")
                return
            }
            self.friends = friendList
            DispatchQueue.main.async(execute: {self.do_table_refresh()})
        }
    }
    
    func do_table_refresh() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = friends[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let qs = QueryService()
        let cell = tableView.cellForRow(at: indexPath) as! UITableViewCell
        
        
        let selected_friend = cell.textLabel?.text!
        let navigationVC = NavigationViewController()
        
        qs.lookup(friend_name: selected_friend!) // add check to see if selected_friend is nill
        {
            response in
            guard let location = response else {
                print("No loction received.")
                return
            }
            // send friend_location to NavigationViewController
            navigationVC.destination = location
        }
    
        self.performSegue(withIdentifier: "showNavigation", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.friends.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Called before segue is performed to set parameters in Target View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is NavigationViewController
        {
            let vc = segue.destination as? NavigationViewController
            
            qs.lookup(friend_name: selected_friend) // add check to see if selected_friend is nill
            {
                response in
                guard let location = response else {
                    print("No loction received.")
                    return
                }
                // send friend_location to NavigationViewController
                vc?.destination = location
            }
            // hardcoded value to use for testing if segue destination is set properly
            // vc?.destination = CLLocationCoordinate2D(latitude: 34.0688, longitude: -118.4440)
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

extension HomeViewController: CLLocationManagerDelegate {
    // called whenever user's location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: range, longitudinalMeters: range)
        mapView.setRegion(region, animated: true)
    }
    
    // called whenever permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}



