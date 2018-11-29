//
//  QueryService.swift
//  HTTP_POST_EXAMPLE
//
//  Created by Ariel Peterson on 11/15/18.
//  Copyright © 2018 Ariel Peterson and An Mary Nguyen. All rights reserved.

import UIKit
import Foundation
import MapKit

import Alamofire


// Must change each time we run ngrok
let SERVER = "http://ae57e33d.ngrok.io"

class QueryService {
    typealias JSONDictionary = [String: Any]
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Adds a new user to the database.
    func addUser(user_name :String) {
        let urlString = SERVER + "/addUser"
        let parameters : Parameters = ["user_name" : user_name]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Adds friend to user's friends list.
    func addFriend(user_name :String, friend_name :String){
        let urlString = SERVER + "/addFriend"
        let parameters : Parameters = ["user_name" : user_name, "friend_name": friend_name]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Remove friend from user's friend list
    func deleteFriend(user_name :String, friend_name :String) {
        let urlString = SERVER + "/deleteFriend"
        let parameters : Parameters = ["user_name" : user_name, "friend_name": friend_name]
        Alamofire.request(urlString, parameters: parameters).response { response in
            // Handle response
            debugPrint(response)
        }
    }
    
    // Get friends list. Note has a completion handler because asynchronous
    func getFriends(user_name: String, completion: @escaping ([String]?) -> Void) {
        let urlString = SERVER + "/getFriends"
        let parameters : Parameters = ["user_name" : user_name]
        Alamofire.request(urlString, parameters: parameters).response { response in
            
            guard let data = response.data else {
                print("No friend's list received")
                completion(nil)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Array<String>]
            
            // TODO: Error check            
            // Upon completion, return friends list
            completion((json?["friends"])!)
        }
    }
    
    // Register a user's most recent location.
    func registerLocation(user_name :String, location : CLLocationCoordinate2D) {
        let urlString = SERVER + "/registerLocation"
        
        // Store MKCoordinateREgion as JSON?
        let params : [String:Any] = ["user_name" :  user_name, "location": ["latitude": location.latitude, "longitude": location.latitude]]
        Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            // Handle resonse
            debugPrint(response)
        }
    }
    
    // Looks up location of a friend for a given user. Note has completion handler
    func lookup(user_name :String, friend_name :String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        
        let urlString = SERVER + "/lookup"
        let parameters : Parameters = ["user_name" : user_name, "friend_name": friend_name]
        Alamofire.request(urlString, parameters: parameters).responseJSON
            { response in
                guard let location = response.result.value as? [String: Double] else {
                    print("Malformed loction data")
                    completion(nil)
                    return
                }
                
                // Upon completion, return a the latitude and longitude
                completion(CLLocationCoordinate2DMake(location["latitude"]!, location["longitude"]!))
        }
    }
    
    // Toggle user's location sharing on and off.
    func toggle(user_name :String) {
        let urlString = SERVER + "/toggle"
        let parameters : Parameters = ["user_name" : user_name]
        Alamofire.request(urlString, parameters: parameters).response { response in debugPrint(response) }
    }

}
