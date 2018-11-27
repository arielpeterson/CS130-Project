//
//  ViewController.swift
//  HTTP_POST_EXAMPLE
//
//  Created by Ariel Peterson on 11/15/18.
//  Copyright © 2018 Ariel Peterson. All rights reserved.
//

import UIKit
import Foundation

// Must change each time we run ngrok
let SERVER = "http://66e5dd3c.ngrok.io"

class ViewController: UIViewController {
    typealias JSONDictionary = [String: Any]
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let user_name = "Ariel"
        
        dataTask?.cancel()
        let url = NSURL(string: SERVER+"/addUser?user_name=Ariel")!
        //let message = "user_name=" + user_name

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        //request.httpBody = message.data(using: String.Encoding.utf8)
        
        dataTask = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                print(self.errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                1 == 1
                {
                print(data)
                print(response)
            }

        }
        dataTask?.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

