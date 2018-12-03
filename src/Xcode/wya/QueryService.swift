//
//  QueryService.swift
//  HTTP_POST_EXAMPLE
//
//  Created by Ariel Peterson on 11/15/18.
//  Copyright © 2018 Ariel Peterson and An Mary Nguyen. All rights reserved.

import UIKit
import Foundation
import MapKit

import GoogleSignIn
import Alamofire


// Must change each time we run ngrok

let SERVER = "http://8efa8e6c.ngrok.io"


class QueryService {
    typealias JSONDictionary = [String: Any]
    var errorMessage = ""
    var username_ : String
    var user_email_ : String

    init() {
        // We are using email for username
        username_ =  (GIDSignIn.sharedInstance().currentUser?.profile.givenName)!
        user_email_ =  (GIDSignIn.sharedInstance().currentUser?.profile.email)!
    }
    
    // Adds a new user to the database.
    func addUser() {
        let urlString = SERVER + "/addUser"
        let parameters : Parameters = ["user_email": user_email_, "user_name" : username_]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Adds friend to user's friends list.
    // AND add user to friend's friend list
    func addFriend(friend_email :String){
        let urlString = SERVER + "/addFriend"
        var parameters : Parameters = ["user_email" : user_email_, "friend_email": friend_email]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
        parameters = ["user_email" : friend_email, "friend_email": user_email_]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
        
    }
    
    // Remove friend from user's friend list
    // AND remove user from friend's friend list
    func deleteFriend(friend_email :String) {
        let urlString = SERVER + "/deleteFriend"
        var parameters : Parameters = ["user_email" : user_email_, "friend_email": friend_email]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
        parameters = ["user_email" : friend_email, "friend_email": user_email_]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Get friends list. Note has a completion handler because asynchronous
    func getFriends(completion: @escaping ([String]?) -> Void) {
        let urlString = SERVER + "/getFriends"
        var parameters : Parameters = ["user_email" : user_email_]
        Alamofire.request(urlString, parameters: parameters).response { response in
            
            guard let data = response.data else {
                print("No friend's list received")
                completion(nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Array<String>] else {
                print("No json data received")
                completion(nil)
                return
            }
            
            // Upon completion, return friends list
            
            completion((json["friends"])!)
        }
    }
    
    // Register a user's most recent location.
    func registerLocation(location : CLLocationCoordinate2D) {
        let urlString = SERVER + "/registerLocation"
        // Store MKCoordinateREgion as JSON?
        let params : [String:Any] = ["user_email" :  user_email_, "location": ["latitude": location.latitude, "longitude": location.longitude]]
        let request = Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            // Handle resonse
            debugPrint(response)
        }
    }
    
    // Looks up location of a friend for a given user. Note has completion handler
    func lookup(friend_email :String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        
        let urlString = SERVER + "/lookup"
        let parameters : Parameters = ["user_email" : user_email_, "friend_email": friend_email]
        Alamofire.request(urlString, parameters: parameters).responseJSON
            { response in
                guard let data = response.data else {
                    print("No location received")
                    completion(nil)
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] else {
                    print("No json data received")
                    completion(nil)
                    return
                }
                
                
                // Parse response
                let location = json["location"] as! [String:AnyObject]
                let outdoor_location = location["outdoor_location"]
                print(outdoor_location)
                print(location)
                
                let latitude = outdoor_location!["latitude"] as! Double
                let longitude = outdoor_location!["longitude"] as! Double
                // Indoor Location
                let indoor_location = location["indoor_location"]
                
                
                
                //let indoor_location = json["indoor_location"] as! [String:Any]
                
                
                
                // Upon completion, return a the latitude and longitude
                
                completion(CLLocationCoordinate2DMake(latitude, longitude))
        }
    }
    
    // Toggle user's location sharing on and off.
    func toggle() {
        let urlString = SERVER + "/toggle"
        let parameters : Parameters = ["user_email" : user_email_]
        Alamofire.request(urlString, parameters: parameters).response { response in debugPrint(response) }
    }
    
    // Get a user's name based on their email
    func getName(email: String, completion: @escaping (String?) -> Void) {
        let urlString = SERVER + "/getName"
        let parameters : Parameters = ["email" : email]
        Alamofire.request(urlString, parameters: parameters).response { response in
            
            guard let data = response.data else {
                print("No friend's list received")
                completion(nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:String] else {
                print("No json data received")
                completion(nil)
                return
            }
            
            // Upon completion, return the user's name
            completion(json["name"])
        }
    }
    
    // Add floor plan of building
    func addFloor(building_name: String, floor_number: String, floor_plan: UIImage) {
        let urlString = SERVER + "/addFloor"
        let parameters : Parameters = ["building_name" : building_name, "floor_number" : floor_number, "floor_plan" : floor_plan]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Add building model
    func addBuilding(building_name: String, longitude: Double, latitude: Double) {
        let urlString = SERVER + "/addBuilding"
        let parameters : Parameters = ["building_name" :  building_name, "longitude": longitude, "latitude": latitude]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Get building location, number of floors
    func getBuildingMetadata(building_name: String, completion: @escaping ([String:Any]?) -> Void) {
        let urlString = SERVER + "/getBuildingMetadata"
        let parameters : Parameters = ["building_name" : building_name]
        Alamofire.request(urlString, parameters: parameters).response { response in
            
            guard let data = response.data else {
                print("No metadata received")
                completion(nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: [])  as! [String:Any] else {
                print("No json data received")
                completion(nil)
                return
            }
            
            // Upon completion, return the JSON object
            completion(json)
        }
    }
    
    // Get floor plan image
    func getFloorImage(building_name: String, floor: Int, completion: @escaping (UIImage?) -> Void) {
        let urlString = SERVER + "/getFloorImage"
        let parameters : Parameters = ["building_name" : building_name, "floor" : floor]
        Alamofire.request(urlString, parameters: parameters).response { response in
            
            guard let data = response.data else {
                print("No image received")
                completion(nil)
                return
            }
            
            // Upon completion, return the image
            completion(UIImage(data: data))
        }
    }
    
    // Get buildings within radius of location
    func getBuildingByRadius() {
        
    }
}
