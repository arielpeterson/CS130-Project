//
//  MapViewControllerDelegate.swift
//  wya
//
//  Created by Brad Squicciarini on 11/27/18.
//  Copyright © 2018 com.example. All rights reserved.
//

import UIKit

@objc
protocol MapViewControllerDelegate {
    @objc optional func toggleMenuPanel()
    @objc optional func collapseSidePanels()
}
