//
//  HamburgerLayer.swift
//  Menu
//
//  Created by Zeeshan Khan on 5/25/17.
//  Copyright © 2017 Zeeshan Khan. All rights reserved.
//

import UIKit

enum HamburgerLayer {
    case home
    case viewFriends
    case addFloorplan
    case account
    case signout
    
    var name: String {
        switch self {
        case .home: return "Home"
        case .viewFriends : return "View Friends"
        case .addFloorplan: return "Add Floorplan"
        case .account: return "My Account"
        case .signout: return "Sign Out"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "homeIcon"
        case .viewFriends: return "homeIcon"
        case .addFloorplan: return "documentsIcon"
        case .account: return "paymentIcon"
        case .signout: return "giftIcon"
        }
    }
    
    var identifier: String {
        return "HamburgerCell"
    }
}

