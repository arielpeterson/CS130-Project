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
    
    let qs = QueryService()
    var errorMessage = ""
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let SERVER = "http://c02c0a92.ngrok.io"

    let locationManager = CLLocationManager()
    let range:Double = 1000
    
    var friends : [String] = []
    var user_name : String = ""
    var selected_friend : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get friends
        tableView.register(HomeViewCell.self, forCellReuseIdentifier: "customcell")
        checkLocationServices()

        qs.getFriends(user_name: "Ariel") { response in
            guard let friendList = response else {
                print("No friends! :(")
                return
            }
            self.friends = friendList
            DispatchQueue.main.async(execute: {self.do_table_refresh()})
        }
    }
    
    func do_table_refresh()
    {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! HomeViewCell
        cell.nameLabel.text = friends[indexPath.row]
        cell.myHomeViewController = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let qs = QueryService()
        let cell = tableView.cellForRow(at: indexPath) as! HomeViewCell
        
        // TODO: This is returing nil. idk why
        selected_friend = cell.nameLabel.text!
        
        // TO DO: uncommet this line when return type from qs.lookup is CLLocationCoordinate2D
        // Change to wait for completionHandler from query
        
        let user = GIDSignIn.sharedInstance().currentUser
        user_name = (user?.profile.givenName)!
        
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
            
            qs.lookup(user_name: user_name, friend_name: selected_friend) // add check to see if selected_friend is nill
            {
                response in
                guard let location = response else {
                    print("No loction received.")
                    return
                }
                // send friend_location to NavigationViewController
                // Hard coded location to test if segue destination is set properly
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

class HomeViewCell : UITableViewCell {
    
    var myHomeViewController: HomeViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
    }
    
    
}

