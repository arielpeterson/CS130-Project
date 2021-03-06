//
//  AppDelegate.swift
//  testing
//
//  Created by Arti Patankar on 11/14/18.
//  Copyright © 2018 com.example. All rights reserved.
//
import UIKit
import GoogleSignIn

@UIApplicationMain
// [START appdelegate_interfaces]
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    // [END appdelegate_interfaces]
    var window: UIWindow?
    //let qs =  QueryService()
    
    // [START didfinishlaunching]
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "45436180371-0k9ahq8sekcii5a2igt33mt49j72lobn.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    // [END didfinishlaunching]
    // [START openurl]
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    // [END openurl]
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    // [START signin_handler]
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server

            // Add user if they don't exist, otherwise does nothing
            let qs = QueryService()
            qs.addUser()
            
            // [START_EXCLUDE]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in user"])
            // [END_EXCLUDE]
        }
    }
    // [END signin_handler]
    // [START disconnect_handler]
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
    // [END disconnect_handler]
}
