//
//  MenuView.swift
//  wya
//
//  Created by Brad Squicciarini on 11/27/18.
//  Copyright © 2018 com.example. All rights reserved.
//

import UIKit
import GoogleSignIn


class MenuViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has signed out."])
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
