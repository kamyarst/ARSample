//
//  PaintViewController.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import UIKit
import SceneKit
import ARKit

class PaintViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Property
    // MARK: Outlet
    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var colorButton: UIButton!
    @IBOutlet private weak var drawButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    
    // MARK: Variable
    private let node = SCNNode()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
        self.buildBrush()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _ = node.childNodes.map { $0.removeFromParentNode() }
        self.sceneView.session.pause()
    }
    
    // MARK: - Setup
    private func setupScene() {
        
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.debugOptions = [.showFeaturePoints]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    // MARK: - Build
    private func buildBrush() {
        
        let shape = SCNSphere(radius: CGFloat(slider.value))
        shape.firstMaterial?.diffuse.contents = UIColor.systemYellow
        shape.firstMaterial?.specular.contents = UIColor.white
        let node = SCNNode(geometry: shape)
        node.name = "curser"
        self.node.addChildNode(node)
    }
    
    @IBAction func changeColorTapped(_ sender: UIButton) {
        
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.selectedColor = sender.backgroundColor ?? .orange
        self.present(picker, animated: true)
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        node.childNodes.forEach { (node) in
            if node.name != "curser" { node.removeFromParentNode() }
        }
    }
}

// MARK: - ARSCNViewDelegate
extension PaintViewController {
    
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        
        let orientation = SCNVector3(-transform.m31,
                                     -transform.m32,
                                     -transform.m33)
        
        let location = SCNVector3(transform.m41,
                                  transform.m42,
                                  transform.m43)
        
        let position = location + orientation
        
        DispatchQueue.main.async {
            
            if self.drawButton.isHighlighted {
                self.drawButton.setTitle("", for: .normal)
                let curser = self.node.childNode(withName: "curser", recursively: false)
                let shape = SCNSphere(radius: CGFloat(self.slider.value))
                shape.firstMaterial?.diffuse.contents = curser?.geometry?.firstMaterial?.diffuse.contents
                shape.firstMaterial?.specular.contents = UIColor.white
                let node = SCNNode(geometry: shape)
                node.position = position
                self.node.addChildNode(node)
            } else {
                let curser = self.node.childNode(withName: "curser", recursively: false)
                curser?.position = position
                (curser?.geometry as? SCNSphere)?.radius = CGFloat(self.slider.value)
            }
        }
    }
}

extension PaintViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
        let curser = self.node.childNode(withName: "curser", recursively: false)
        curser?.geometry?.firstMaterial?.diffuse.contents = viewController.selectedColor
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    .init(left.x + right.x,
          left.y + right.y,
          left.z + right.z)
}
