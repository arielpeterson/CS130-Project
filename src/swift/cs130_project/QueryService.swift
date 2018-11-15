//
//  QueryService.swift
//  AddFriends
//
//  Created by CLICC User on 11/14/18.
//  Copyright © 2018 CS130. All rights reserved.
//

import Foundation

class QueryService {
    typealias JSONDictionary = [String: Any]
    
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Send current user's info to database
    func signUp(_ user_name: String) {
        dataTask?.cancel()
        let url = NSURL(string: SERVER+"/addUser")!
        let message = "user_name=" + user_name
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = message.data(using: String.Encoding.utf8)
        
        dataTask = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                print(self.errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                    if let stringData = String(data: data, encoding: String.Encoding.utf8) {
                        print(stringData) //JSONSerialization
                    }
                }
        }
        dataTask?.resume()
    }
}
    

