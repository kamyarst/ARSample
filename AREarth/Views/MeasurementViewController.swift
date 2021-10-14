//
//  MeasurementViewController.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import ARKit
import SceneKit
import UIKit

final class MeasurementViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!

    private let session = ARSession()
    private let vectorZero = SCNVector3()
    private let sessionConfig = ARWorldTrackingConfiguration()
    private var measuring = false
    private var startValue = SCNVector3()
    private var endValue = SCNVector3()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.sceneView.session.pause()
    }
    
    // MARK: - Setup
    
    private func setupScene() {
        
        self.sceneView.delegate = self
        self.sceneView.session = self.session
        self.session.run(self.sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        self.resetValues()
    }
    
    private func setupARSession() {
        
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        self.session.run(self.sessionConfig, options: [.resetTracking, .removeExistingAnchors])
    }

    func resetValues() {

        self.measuring = false
        self.startValue = SCNVector3()
        self.endValue = SCNVector3()
        self.updateResultLabel(0.0)
    }

    func updateResultLabel(_ value: Float) {

        let cm = value * 100.0
        let inch = cm * 0.3937007874
        self.resultLabel.text = String(format: "%.2f cm / %.2f\"", cm, inch)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        DispatchQueue.main.async {
            self.detectObjects()
        }
    }

    func detectObjects() {

        if let worldPos = sceneView.realWorldVector(screenPos: view.center) {
            if self.measuring {
                if self.startValue == self.vectorZero {
                    self.startValue = worldPos
                }
                self.endValue = worldPos
                self.updateResultLabel(self.startValue.distance(from: self.endValue))
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.resetValues()
        self.measuring = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.measuring = false
        self.resultLabel.text = "Hold to measure"
    }
}
