//
//  HamburgerViewModel.swift
//  Menu
//
//  Created by Zeeshan Khan on 5/26/17.
//  Copyright © 2017 Zeeshan Khan. All rights reserved.
//

import Foundation

class HamburgerViewModel: NSObject {
    
    func allLayers() -> [HamburgerLayer] {
        
        var layers: [HamburgerLayer] = []
        
        layers.append(.home)
        layers.append(.viewFriends)
        layers.append(.addBuilding)
        layers.append(.addFloorplan)
        layers.append(.account)
        layers.append(.signout)
        
        return layers
    }
}
