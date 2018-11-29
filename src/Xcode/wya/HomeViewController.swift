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
    
    var errorMessage = ""
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let SERVER = "http://c02c0a92.ngrok.io"

    let locationManager = CLLocationManager()
    let range:Double = 1000
    
    var friends : [String] = []
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriends(user_name: "Ariel")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "customcell")
        tableView.dataSource = self
        tableView.delegate = self
        checkLocationServices()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath as IndexPath)
        cell.textLabel?.text = friends[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showNavigation", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.friends.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    func getFriends(user_name: String)  {
        
        var friends : Array<String> = []
        dataTask?.cancel()
        let url_string = SERVER+"/getFriends?user_name="+user_name
        let url = NSURL(string: url_string)!
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        
        dataTask = defaultSession.dataTask(with: request as URLRequest) {
            data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                print(self.errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            {
                // data sent back from server is a json_object
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Array<String>]
                friends = (json?["friends"])!
                for friend in friends {
                    self.friends.append(friend)
                }
                print(response)
                self.tableView.reloadData()
            }
        }
        dataTask?.resume()
        
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


