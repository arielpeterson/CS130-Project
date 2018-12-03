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
    let scene = SCNScene()
    var  plane : SCNPlane?
    var markerNode : SCNNode?
    let qs = QueryService()
    var x : CGFloat = -1.0
    var y : CGFloat = -1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(placePin(_:)))
        sceneView.addGestureRecognizer(tap)
        
        plane = SCNPlane(width: 0.01, height: 0.01)
       // plane!.firstMaterial?.diffuse.contents = UIColor(red: 30.0 / 255.0, green: 150.0 / 255.0, blue: 30.0 / 255.0, alpha: 1)
        markerNode = SCNNode(geometry: plane)
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
        if sender.state == .ended  {
            let tapLocation = sender.location(in: sceneView)
            markerNode!.position = sceneView.unprojectPoint(SCNVector3(tapLocation.x, tapLocation.y, 0.1))
            scene.rootNode.addChildNode(markerNode!)
            self.x = tapLocation.x
            self.y = tapLocation.y

            //
//            let sayButtonT = UIButton(type: .system)
//            button.setTitle("Done")
//            sayButtonT.addTarget(self, action: #selector(unwindToHome(_:)), for: .touchUpInside)
            
            let button1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(unwindToHome))
            // action:#selector(Class.MethodName) for swift 3
            self.navigationItem.rightBarButtonItem  = button1
        }
    }
    @objc
    func unwindToHome(_ sender: Any) {
        qs.registerIndoor(location: Array([self.building!, self.floor!, self.x, self.y]))
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
}
