//
//  QueryService.swift
//  HTTP_POST_EXAMPLE
//
//  Created by Ariel Peterson on 11/15/18.
//  Copyright © 2018 Ariel Peterson and An Mary Nguyen. All rights reserved.

import UIKit
import Foundation

// Must change each time we run ngrok
let SERVER = "http://c02c0a92.ngrok.io"

class QueryService {
    typealias JSONDictionary = [String: Any]
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Adds a new user to the database.
    func addUser(user_name :String) {
        dataTask?.cancel()
        let url_string = SERVER+"/addUser?user_name="+user_name
        let url = NSURL(string: url_string)!
        var return_value = false
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
                print(data)
                print(response)
                
            }
        }
        dataTask?.resume()
        
    }
    
    // Adds friend to user's friends list.
    func addFriend(user_name :String, friend_name :String){
        dataTask?.cancel()
        let url_string = SERVER+"/addFriend?user_name="+user_name+"&friend_name="+friend_name
        let url = NSURL(string: url_string)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        
        dataTask = defaultSession.dataTask(with: request as URLRequest) {
            // data is the data returned from the server
            // response is the response metadata
            // error is an error object that indicates why the request failed
            data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                print(self.errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            {
                print(data)
                print(response)
                
            }
        }
        
        dataTask?.resume()
        
    }
    
    // Remove friend from user's friend list
    func deleteFriend(user_name :String, friend_name :String) {
        dataTask?.cancel()
        let url_string = SERVER+"/deleteFriend?user_name="+user_name+"&friend_name="+friend_name
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
                print(data)
                print(response)
                
            }
        }
        dataTask?.resume()
        
    }
    
    
    func getFriends(user_name: String) -> Array<String>{
        
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
                print(response)
            }
        }
        dataTask?.resume()
        return friends
    }
    // Register a user's most recent location.
    // Is JSONDictionary the right type to use?
    func registerLocation(user_name :String, location :JSONDictionary) {
        dataTask?.cancel()
        let url_string = SERVER+"/registerLocation"
        let url = NSURL(string: url_string)!
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        // request.httpBody =
        // Add body to include user_name and location
        
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
                print(data)
                print(response)
                
            }
        }
        dataTask?.resume()
        
    }
    
    // Looks up location of a friend for a given user.
    func lookup(user_name :String, friend_name :String) {
        dataTask?.cancel()
        let url_string = SERVER+"/lookup?user_name="+user_name+"&friend_name="+friend_name
        let url = NSURL(string: url_string)!
        var return_value = false
        
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
                print(data)
                print(response)
                
            }
        }
        dataTask?.resume()
    }
    
    // Toggle user's location sharing on and off.
    func toggle(user_name :String) {
        dataTask?.cancel()
        let url_string = SERVER+"/toggle?user_name="+user_name
        let url = NSURL(string: url_string)!
        var return_value = false
        
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
                print(data)
                print(response)
                
            }
        }
        dataTask?.resume()
    }
    
    
}
