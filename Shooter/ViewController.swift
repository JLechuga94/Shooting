//
//  ViewController.swift
//  Shooter
//
//  Created by Julian Lechuga Lopez on 27/6/18.
//  Copyright © 2018 Julian Lechuga Lopez. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

   
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func removeEveryOtherBullet(){
        self.sceneView.scene.rootNode.enumerateChildNodes{(node, _) in
            if node.name == "Bullet"{
                node.removeFromParentNode()
            }
        }
    }

    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        self.removeEveryOtherBullet()
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.name = "Bullet"
//        body.restitution = 0.2
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(bullet)
        
    }
    
    
    @IBAction func addTargets(_ sender: Any) {
        self.addEgg(x:5, y: 0, z: -40)
        self.addEgg(x: 0, y: 0, z: -40)
        self.addEgg(x: -5, y: 0, z: -40)
    }
    
    func addEgg(x: Float, y: Float, z: Float){
        let eggScene = SCNScene(named: "Media.scnassets/egg.scn")
        let eggNode = (eggScene?.rootNode.childNode(withName: "egg", recursively: false))!
        eggNode.position = SCNVector3(x,y,z)
        eggNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode, options: nil))
        self.sceneView.scene.rootNode.addChildNode(eggNode)
    }


}
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
