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
    var building : String?
    var floor : String?
    var marker : SCNNode?
    let qs = QueryService()
    let scene = SCNScene()

    // Convert from screen coordinates to world coordinates
    func CGPointToSCNVector3(view: SCNView, depth: Float, point: CGPoint) -> SCNVector3 {
        let projectedOrigin = view.projectPoint(SCNVector3Make(0, 0, depth))
        let locationWithz  = SCNVector3Make(Float(point.x), Float(point.y) - 43, projectedOrigin.z)
        return view.unprojectPoint(locationWithz)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the scene
        sceneView.scene = scene
        sceneView!.allowsCameraControl = false
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(placePin(_:)))
        sceneView.addGestureRecognizer(tap)
        
        // Camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Floorplan Node
        let floorGeometry = SCNPlane(width: 1.0, height: 1.0)
        floorGeometry.firstMaterial?.diffuse.contents = image
        let floorNode = SCNNode(geometry: floorGeometry)
        scene.rootNode.addChildNode(floorNode)
        
        // Marker node
        let triangle = SCNPyramid(width: 0.0025, height: 0.125, length:0.125)
        triangle.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 101/255, green: 182/255, blue: 245/255, alpha: 1)
        marker = SCNNode(geometry: triangle);
        marker!.transform = SCNMatrix4Rotate(marker!.transform, Float.pi/2,0,1,0)
        marker!.transform = SCNMatrix4Rotate(marker!.transform, Float.pi, 0,0,1)
        scene.rootNode.addChildNode(marker!)
    }
    
    @objc func placePin(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended  {
            let tapLocation = sender.location(in: sceneView)
            marker!.position = CGPointToSCNVector3(view: sceneView, depth: 0, point: CGPoint(x: tapLocation.x, y: tapLocation.y))
            let done_button = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(unwindToHome))
            self.navigationItem.rightBarButtonItem  = done_button
        }
    }
    
    @objc func unwindToHome(_ sender: Any) {
        // Save marker's location (in world coordinates)
        qs.registerIndoor(location: [self.building!, self.floor!, marker!.position.x, marker!.position.y, marker!.position.z])
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
}
