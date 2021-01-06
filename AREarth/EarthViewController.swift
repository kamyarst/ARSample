//
//  ViewController.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import UIKit
import SceneKit
import ARKit

class EarthViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Property
    // MARK: Outlet
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: Variable
    private let node = SCNNode()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        self.buildSphare()
        self.buildShip()
        self.animate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Register
    // MARK: - Setup
    private func setupScene() {
        
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.scene.rootNode.addChildNode(self.node) 
    }
    
    // MARK: - Build
    private func buildSphare() {
        
        let sphare = SCNSphere(radius: 0.05)
        sphare.firstMaterial?.diffuse.contents = UIImage(named: "earth.jpg")
        sphare.firstMaterial?.specular.contents = UIColor.yellow
        let node = SCNNode(geometry: sphare)
        self.node.addChildNode(node)
    }
    
    private func buildShip() {
        
        guard let ship = SCNScene(named: "art.scnassets/ship.scn")?
                .rootNode.childNode(withName: "ship", recursively: false)
        else { return }
        ship.position = .init(x: 1, y: 0, z: 0)
        ship.scale = .init(x: 0.3, y: 0.3, z: 0.3)
        ship.eulerAngles = .init(0, 180.toRadius, 0)
        node.addChildNode(ship)
    }

    // MARK: - Function
    private func animate() {
        
        let rotateAnimation = SCNAction.rotate(by: 360.toRadius,
                                               around: .init(x: 0, y: 1, z: 0),
                                               duration: 8)
        let rotateForEver = SCNAction.repeatForever(rotateAnimation)
        node.runAction(rotateForEver)
    }
}

// MARK: - ARSCNViewDelegate
extension EarthViewController {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
