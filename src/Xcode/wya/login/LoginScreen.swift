//
//  LoginScreen.swift
//  wya
//
//  Created by Brad Squicciarini on 11/26/18.
//  Copyright © 2018 com.example. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginScreen: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signInSilently()         // Automatically signs in user
        
        // This will registers the receiveToggleAuthUINotification() everytime we login/logout
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginScreen.receiveToggleAuthUINotification(_:)),
                                               name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                               object: nil)
        
        toggleAuthUI()
    }

    // If we are authorized transition to next view
    func toggleAuthUI() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
           // signInButton.isHidden = true
            self.performSegue(withIdentifier: "login_to_map", sender: self)
        } else {
           // signInButton.isHidden = false
        }
    }
    
    // Function that is called when ToggleAuthUINotification is received from Google Signin
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            self.toggleAuthUI()
            if notification.userInfo != nil {
                // Assuming this just holds userInfo. Not sure
                guard let userInfo = notification.userInfo as? [String:String] else { return }
            }
        }
    }
    
    // Honestly, not sure why this is necessary. I couldn't get it to segue to MapScreen without it
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
        
    // Destructor
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }


}
