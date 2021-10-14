//
//  ViewController.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import ARKit
import UIKit

final class EarthViewController: UIViewController, ARSCNViewDelegate {

    // MARK: Outlet

    @IBOutlet var sceneView: ARSCNView!

    // MARK: Variable

    private var viewModel = EarthViewModel()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupARSession()
        self.viewModel.buildWholeWorld()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.sceneView.session.pause()
    }

    // MARK: - Setup

    private func setupScene() {

        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.scene.rootNode.addChildNode(self.viewModel.node)
    }
    
    private func setupARSession() {
        
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        let config = self.viewModel.getARConfiguration()
        self.sceneView.session.run(config)
    }
}
