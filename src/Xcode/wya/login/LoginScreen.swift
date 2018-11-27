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
    
    // For unwind segue
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }

    // If we are authorized transition to next view
    func toggleAuthUI() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Authorized!. Do stuff...
            self.performSegue(withIdentifier: "login_segue", sender: self)
        } else {
           // Signed out. Do stuff we need...
        }
    }
    
    // Function that is called whenever we sign in or out of google
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            
            // TODO: Workaround
            // Waits 0.4 seconds before calling toggleAuthUI() Otherwise, SFAuthenticationViewController
            // is still alive and we get an error. But fix is not high priority
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {self.toggleAuthUI()})
            
            if notification.userInfo != nil {
                // Assuming this just holds userInfo. Not sure
                guard let userInfo = notification.userInfo as? [String:String] else { return }
            }
        }
    }
    
    // Destructor
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }


}
