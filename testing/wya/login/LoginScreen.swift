//
//  LoginScreen.swift
//  wya
//
//  Created by Brad Squicciarini on 11/26/18.
//  Copyright © 2018 com.example. All rights reserved.
//

import UIKit
import GoogleSignIn

class TestViewController: UIViewController, GIDSignInUIDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
