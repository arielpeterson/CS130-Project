//
//  AddFloorplanViewController.swift
//  wya
//
//  Created by Brad Squicciarini on 11/29/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

