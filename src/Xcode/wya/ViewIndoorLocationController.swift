//
//  ViewIndoorLocationController.swift
//  wya
//
//  Created by Arti Patankar on 12/3/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import SceneKit

class ViewIndoorLocationController: UIViewController {
    
    
    @IBOutlet weak var sceneView: SCNView!
    
    var image = UIImage()
    let scene = SCNScene()
    var markerNode : SCNNode?
    var indoorLocationPoint = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        scene.rootNode.addChildNode(cameraNode)


        let plane = SCNPlane(width: 0.5, height: 0.5)
        let markerNode = SCNNode(geometry: plane)
        scene.rootNode.addChildNode(markerNode)
        plane.firstMaterial?.diffuse.contents  = UIColor(red: 30/255, green: 150/255, blue: 30/255, alpha: 1)
        markerNode.position = sceneView.unprojectPoint(SCNVector3(187, 403, 0))
        
        let floorGeometry = SCNPlane(width: 1.0, height: 1.0)
        floorGeometry.firstMaterial?.diffuse.contents = image
        let floorNode = SCNNode(geometry: floorGeometry)
        scene.rootNode.addChildNode(floorNode)

        sceneView.scene = scene
        sceneView.allowsCameraControl = true
    }
}

