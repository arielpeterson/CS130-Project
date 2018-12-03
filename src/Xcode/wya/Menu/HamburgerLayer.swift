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
    case addBuilding
    case addFloorplan
    case signout
    
    var name: String {
        switch self {
        case .home: return "Home"
        case .viewFriends : return "View Friends"
        case .addBuilding : return "Add Building"
        case .addFloorplan: return "Add Floor Plan"
        case .signout: return "Sign Out"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "homeIcon"
        case .viewFriends: return "homeIcon"
        case .addBuilding: return "homeIcon"
        case .addFloorplan: return "documentsIcon"
        case .signout: return "giftIcon"
        }
    }
    
    var identifier: String {
        return "HamburgerCell"
    }
}

