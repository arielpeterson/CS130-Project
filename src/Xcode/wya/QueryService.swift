//
//  HttpRequest.swift
//  HTTP_POST_EXAMPLE
//
//  Created by Ariel Peterson on 11/15/18.
//  Copyright © 2018 Ariel Peterson. All rights reserved.
//

import UIKit
import Foundation

// Must change each time we run ngrok
let SERVER = "http://ff82a439.ngrok.io"

class QueryService {
    typealias JSONDictionary = [String: Any]
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func addUser(user_name: String) {
        
        // Do any additional setup after loading the view, typically from a nib.
        //let user_name = "Ariel"
        
        dataTask?.cancel()
        let url = NSURL(string: SERVER+"/addUser?user_name="+user_name)! // change to use user_name from function parameter
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        
        
        dataTask = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                print(self.errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 // change to check response code
            {
                print(data)
                print(response)
            }
            
        }
        dataTask?.resume()
        
        
    }
    
}
