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
    let SERVER = "http://c02c0a92.ngrok.io"
    let qs = QueryService()
    
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
            cell.nameLabel?.text = friends[indexPath.row]
            cell.cellDelegate = self
            cell.index = indexPath
            return cell
        
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Friend", message: "Enter your friend's name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Name"
        }
        
        alert.addAction(UIAlertAction(title: "ENTER", style: .default, handler: { [weak alert] (_) in
            let add_friend_name = alert!.textFields![0].text // Force unwrapping because we know it exists.
            self.qs.addFriend(friend_name: add_friend_name!)
            self.friends.append(add_friend_name!)
            //print("Text field: \(UITextField.text)")
            self.do_table_refresh()
        }))
    
        self.present(alert, animated: true, completion:nil)
        
    }
    
}


extension ViewFriendsController: TableViewNew {
    func onDeleteCell(index: Int, cell: MyTableViewCell) {
        print(index)
        let deletionIndexPath = tableView.indexPath(for: cell)
        let user = GIDSignIn.sharedInstance().currentUser
        let user_name = (user?.profile.givenName)!
        
        let delete_friend_name = friends[index]
            // get friend's name
        friends.remove(at: index)
        // do a database call to delete friend
        let qs = QueryService()
        qs.deleteFriend(friend_name: delete_friend_name)
        tableView.deleteRows(at: [deletionIndexPath!], with: .automatic)
    }
}

