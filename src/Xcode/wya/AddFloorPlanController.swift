//
//  AddFloorPlanController.swift
//  wya
//
//  Created by Arti Patankar on 12/1/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import SceneKit

class AddFloorPlanController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!

    var image = UIImage()
    let scene = SCNScene()
    let qs = QueryService()
    var building = ""
    var floorNum = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buildingAlert = UIAlertController(title: "Enter Building Name and Floor Number", message: nil, preferredStyle: .alert)
        buildingAlert.addTextField{
            textField in textField.text = "Building"
        }
        buildingAlert.addTextField {
            textField in textField.text = "1"
        }
        buildingAlert.addAction(UIAlertAction(title: "OK", style: .default)
        {
            action in self.building = buildingAlert.textFields![0].text!
            self.floorNum = buildingAlert.textFields![1].text!
            self.qs.getBuildingMetadata(building_name: self.building) { response in
                if response != nil {}
                else {
                    let nonexistentAlert = UIAlertController(title: "Error", message: "Must add building", preferredStyle: .alert)
                    nonexistentAlert.addAction(UIAlertAction(title: "OK", style: .default) {
                        anotherAction in self.performSegue(withIdentifier: "noBuilding", sender: self)
                    })
                    self.present(nonexistentAlert, animated: true, completion: nil)
                }
            }
        })
        self.present(buildingAlert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        scene.rootNode.addChildNode(cameraNode)
        
        let floorGeometry = SCNPlane(width: 1.0, height: 1.0)
        
        // TEMPORARY
//        let texture = UIImage(contentsOfFile: Bundle.main.path(forResource: "another", ofType: "jpeg")!)
        
//        floorGeometry.firstMaterial?.diffuse.contents = texture
  //      let floorNode = SCNNode(geometry: floorGeometry)
   //
        //scene.rootNode.addChildNode(floorNode)
        
        sceneView.scene = scene
    }
    
    @IBAction func addFloor(_ sender: Any) {
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            // Need to send floor number
            let qs = QueryService()
            qs.addFloor(building_name: self.building, floor_number: self.floorNum, floor_plan: image)
            let floorGeometry = SCNPlane(width: 1.0, height: 1.0)
            floorGeometry.firstMaterial?.diffuse.contents = image
            let floorNode = SCNNode(geometry: floorGeometry)
            self.scene.rootNode.addChildNode(floorNode)
            
            self.sceneView.scene = self.scene
            
        }
    }
}
