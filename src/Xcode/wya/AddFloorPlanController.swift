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
    
    let scene = SCNScene()
    var numFloors = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewFloor(_:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneSetup()
    }
    
    @objc func viewFloor(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let tapLocation = sender.location(in: sceneView)
            
            let node = sceneView.hitTest(tapLocation, options: nil)
            if !node.isEmpty {
                let floor = node.first?.node
                let alert = UIAlertController(title: "Edit Floor", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Modify", style: .default)
                {
                    UIAlertAction in let texture = UIImage(contentsOfFile: Bundle.main.path(forResource: "another", ofType: "jpeg")!)
                    floor?.geometry?.firstMaterial?.diffuse.contents = texture
                })
                alert.addAction(UIAlertAction(title: "Delete", style: .default)
                {
                    UIAlertAction in self.numFloors -= 1
                    floor?.removeFromParentNode()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .default)
                {
                    UIAlertAction in
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func sceneSetup() {
        for floorNum in 1...numFloors {
            let currentGeometry = SCNBox(width: 1, height: 0.01, length: 1, chamferRadius: 0.0)
            let texture = UIImage(contentsOfFile: Bundle.main.path(forResource: "texture", ofType: "jpeg")!)
            currentGeometry.firstMaterial?.diffuse.contents = texture
            let currentNode = SCNNode(geometry: currentGeometry)
            currentNode.position = SCNVector3(0.0, Double(floorNum) * 0.2, 0.0)
            scene.rootNode.addChildNode(currentNode)
        }
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
    }
    
    @IBAction func addFloor(_ sender: Any) {
        let alert = UIAlertController(title: "Add Floor", message: nil, preferredStyle: .alert)
        alert.addTextField{
            textField in textField.text = "1"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default)
        {
            UIAlertAction in let text = alert.textFields![0].text!
            if Double(text) != nil {
                let floorNum = Double(alert.textFields![0].text!)
                self.numFloors += 1
                let currentGeometry = SCNBox(width: 1, height: 0.01, length: 1, chamferRadius: 0.0)
                let texture = UIImage(contentsOfFile: Bundle.main.path(forResource: "texture", ofType: "jpeg")!)
                currentGeometry.firstMaterial?.diffuse.contents = texture
                let currentNode = SCNNode(geometry: currentGeometry)
                currentNode.position = SCNVector3(0.0, floorNum! * 0.2, 0.0)
                self.scene.rootNode.enumerateChildNodes {
                    (node, stop) in if SCNVector3EqualToVector3(node.position, currentNode.position) {
                        self.numFloors -= 1
                        node.removeFromParentNode()
                    }
                    
                }
                self.scene.rootNode.addChildNode(currentNode)
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}
