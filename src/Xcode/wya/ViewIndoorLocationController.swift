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
    
    var image : UIImage?
    let scene = SCNScene()
    var marker : SCNNode?
    var indoorLocation : [String:Any]?
    var qs = QueryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qs.getFloorImage(building_name: indoorLocation!["building"] as! String, floor: indoorLocation!["floor"] as! String) { response in
            guard let img = response else {
                print("Did not get image")
                return
            }
            self.image = img
        

        self.sceneView.scene = self.scene

        // Camera Node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        self.scene.rootNode.addChildNode(cameraNode)
        
        // Floorplan Node
        let floorGeometry = SCNPlane(width: 1.0, height: 1.0)
        floorGeometry.firstMaterial?.diffuse.contents = self.image!
        let floorNode = SCNNode(geometry: floorGeometry)
        self.scene.rootNode.addChildNode(floorNode)
        
        // Marker Node
        // Marker node
        let triangle = SCNPyramid(width: 0.0025, height: 0.125, length:0.125)
        triangle.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 101/255, green: 182/255, blue: 245/255, alpha: 1)
        self.marker = SCNNode(geometry: triangle);
        self.marker!.transform = SCNMatrix4Rotate( self.marker!.transform, Float.pi/2,0,1,0)
        self.marker!.transform = SCNMatrix4Rotate( self.marker!.transform, Float.pi, 0,0,1)
         self.marker!.position = SCNVector3Make( self.indoorLocation!["x"] as! Float,
                                           self.indoorLocation!["y"] as! Float,
                                           self.indoorLocation!["z"] as! Float)
         self.scene.rootNode.addChildNode( self.marker!)
        }
}
}

