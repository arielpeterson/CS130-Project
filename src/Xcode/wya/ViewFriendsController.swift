//
//  ViewFriendsController.swift
//  wya
//
//  Created by Ariel Peterson on 11/29/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import GoogleSignIn


let user = GIDSignIn.sharedInstance().currentUser
let user_name = (user?.profile.givenName)!


class ViewFriendsController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var errorMessage = ""
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let qs = QueryService()
    
    // List of friend's emails
    var friends : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qs.getFriends() { response in
            guard let friendList = response else {
                print("No friends! :(")
                return
            }
            self.friends = friendList
            DispatchQueue.main.async(execute: {self.do_table_refresh()})
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func do_table_refresh(){
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count // +1 for the Add Friend Button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! MyTableViewCell
            qs.getName(email: friends[indexPath.row]) { response in
                guard let name = response else {
                    print("No name for that email address")
                    return
                }
                cell.nameLabel?.text = name
                cell.cellDelegate = self
                cell.index = indexPath
            }
            return cell
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Friend", message: "Enter your friend's email", preferredStyle: .alert)
        let error_email_dne = UIAlertController(title: "Error", message: "No friend with that email exists", preferredStyle: .alert)
        let error_duplicate_friend = UIAlertController(title: "Error", message: "You are already friends with that user", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
            let add_friend_email = alert!.textFields![0].text // Force unwrapping because we know it exists.
            // Check if friend is a user in our database
            self.qs.getName(email: add_friend_email!) { response in
                guard let name = response else {
                    print("No name for that email address")
                    error_email_dne.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(error_email_dne, animated: true, completion: nil)
                    return
                }
            }
            // Check if user is already friends
            if self.friends.contains(add_friend_email!) {
                print("No name for that email address")
                error_duplicate_friend.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(error_duplicate_friend, animated: true, completion: nil)
                return
            }
            
            
            self.qs.addFriend(friend_email: add_friend_email!)
            
            self.friends.append(add_friend_email!)
            //print("Text field: \(UITextField.text)")
            self.do_table_refresh()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        }))
    
        self.present(alert, animated: true, completion:nil)
    
    }
    
    
    
}


extension ViewFriendsController: TableViewNew {
    func onDeleteCell(index: Int, cell: MyTableViewCell) {
        print(index)
        let deletionIndexPath = tableView.indexPath(for: cell)
        let delete_friend_email = friends[index]
        friends.remove(at: index)
        // do a database call to delete friend
        qs.deleteFriend(friend_email: delete_friend_email)
        tableView.deleteRows(at: [deletionIndexPath!], with: .automatic)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
}

