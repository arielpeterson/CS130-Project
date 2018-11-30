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


var friends : [String] = []

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
        
        tableView.register(MyCell.self, forCellReuseIdentifier: "customcell")
        
        qs.getFriends(user_name: "Ariel") { response in
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
    
    func do_table_refresh()
    {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! MyCell
        
        //cell.nameLabel.text = friends[indexPath.row]
        cell.nameLabel.text = friends[indexPath.row]
        cell.myViewFriendsController = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! MyCell
        let selected_friend = cell.nameLabel.text
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")
    }
    
    
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            // get friend's name
            let delete_friend_name = friends[deletionIndexPath.row]
            friends.remove(at: deletionIndexPath.row)
            // do a database call to delete friend
            let qs = QueryService()
            qs.deleteFriend(friend_name: delete_friend_name)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
}

class Header: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "My Friends"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
    }
    
}

class MyCell : UITableViewCell {
    
    var myViewFriendsController: ViewFriendsController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(deleteButton)
        
        deleteButton.addTarget(self, action: #selector(handleDeleteAction), for: .touchUpInside)
        //addButton.addTarget(self, action: #selector(handleAddAction), for: .touchUpInside)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel, "v1": deleteButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": deleteButton]))
        
    }
    
    @objc func handleDeleteAction() {
        myViewFriendsController?.deleteCell(cell: self)
    }
    
    
}
