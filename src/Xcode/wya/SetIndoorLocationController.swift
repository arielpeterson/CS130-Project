//
//  SetIndoorLocationController.swift
//  wya
//
//  Created by Arti Patankar on 12/2/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import SceneKit

class SetIndoorLocationController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    
    var image = UIImage()
    let scene = SCNScene()
    let markerNode = SCNNode(geometry: SCNPlane(width: 0.01, height: 0.01))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(placePin(_:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        scene.rootNode.addChildNode(cameraNode)
        
        let floorGeometry = SCNPlane(width: 1.0, height: 1.0)
        floorGeometry.firstMaterial?.diffuse.contents = image
        let floorNode = SCNNode(geometry: floorGeometry)
        scene.rootNode.addChildNode(floorNode)
        
        sceneView.scene = scene
    }
    
    @objc func placePin(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let tapLocation = sender.location(in: sceneView)
            
            markerNode.position = sceneView.unprojectPoint(SCNVector3(tapLocation.x, tapLocation.y, 0.0))
            scene.rootNode.addChildNode(markerNode)
        }
    }
}
