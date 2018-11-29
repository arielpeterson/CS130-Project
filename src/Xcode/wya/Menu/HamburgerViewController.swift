//
//  HamburgerViewController.swift
//  Menu
//
//  Created by Zeeshan Khan on 5/25/17.
//  Copyright © 2017 Zeeshan Khan. All rights reserved.
//

import UIKit
import GoogleSignIn

class HamburgerViewController: UIViewController {

    @IBOutlet weak var hamburgerTable: UITableView!
    
    var viewModel = HamburgerViewModel()
    var rows: [HamburgerLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rows = viewModel.allLayers()
        hamburgerTable.tableFooterView = UIView()
    }

    //MARK: Menu Actions
    func homeAction() {
        guard let menuVC: MenuViewController = self.parent as? MenuViewController else { return }
        menuVC.hideMenu()
    }
    
    func addFloorplanAction() {
        performSegue(withIdentifier: "addFloorplan_segue", sender: self)
    }
    
    func accountAction() {
        performSegue(withIdentifier: "myAccount_segue", sender: self)
    }
    
    func signOutAction() {
        performSegue(withIdentifier: "unwindToVC1", sender: self)
        GIDSignIn.sharedInstance().signOut()
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has signed out."])
    }


}

extension HamburgerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row: HamburgerLayer = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier, for: indexPath) as! HamburgerCell
        cell.lblTitle.text = row.name
        cell.icon.image = UIImage(named: row.iconName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let menuVC: MenuViewController = self.parent as? MenuViewController else { return }
        menuVC.hideMenu()
        
        let row = rows[indexPath.row]
        
        switch row {
        case .home: homeAction()
        case .addFloorplan: addFloorplanAction()
        case .account: accountAction()
        case .signout: signOutAction()
        }
    }

}
