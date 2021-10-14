//
//  SurfaceViewController.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import ARKit
import Combine
import UIKit

final class SurfaceViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var searchImage: UIImageView!

    private(set) var viewModel = SurfaceViewModel()
    private var bag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSceneView()
        self.initGestureRecognizers()
        self.bindAppState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupARSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.sceneView.session.pause()
    }

    func setupSceneView() {

        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        self.sceneView.showsStatistics = true
        self.sceneView.preferredFramesPerSecond = 60
        self.sceneView.antialiasingMode = .multisampling2X
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }

    private func setupARSession() {

        guard ARWorldTrackingConfiguration.isSupported else { return }

        let config = self.viewModel.getARConfiguration()
        self.sceneView.session.run(config)
    }

    @IBAction func resetButtonPressed(_ sender: Any) {

        self.clearAllFurniture()
        self.resetARsession()
    }

    func resetARsession() {

        let config = self.viewModel.getARConfiguration()
        self.sceneView.session.run(config,
                                   options: [.resetTracking, .removeExistingAnchors])
        self.viewModel.appState = .lookingForSurface
    }

    // MARK: - App status

    func bindAppState() {

        self.viewModel.$appState
            .receive(on: RunLoop.main)
            .sink { state in
                switch state {
                case .lookingForSurface:
                    self.statusImage.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
                case .pointToSurface:
                    self.statusImage.image = UIImage(systemName: "target")
                    self.sceneView.debugOptions = []
                case .readyToFurnish:
                    self.statusImage.image = UIImage(systemName: "checkmark.circle.fill")
                    self.sceneView.debugOptions = []
                }
            }.store(in: &self.bag)
    }

    // MARK: - Adding and removing layers

    func initGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(self.handleScreenTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    func addFurniture(hitTestResult: ARHitTestResult) {
        // Get the real-world position corresponding to
        // where the user tapped on the screen.
        let transform = hitTestResult.worldTransform
        let positionColumn = transform.columns.3 // 4th column; column index starts at 0
        let initialPosition = SCNVector3(positionColumn.x, positionColumn.y, positionColumn.z)

        // Get the current furniture item, correct its position if necessary,
        // and add it to the scene.
        guard let node = SCNScene(named: "art.scnassets/ship.scn")?
            .rootNode.childNode(withName: "ship", recursively: false)
        else { return }
        node.position = initialPosition + SCNVector3(0.3, 0, 0)

        self.sceneView.scene.rootNode.addChildNode(node)
    }

    func clearAllFurniture() {

        self.sceneView.scene.rootNode.enumerateChildNodes { childNode, _ in
            guard let childNodeName = childNode.name, childNodeName != "horizontal"
            else { return }
            childNode.removeFromParentNode()
        }
    }

    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
        // Find out where the user tapped on the screen.
        let tappedSceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: tappedSceneView)

        // Find all the detected planes that would intersect with
        // a line extending from where the user tapped the screen.
        let planeIntersections = tappedSceneView.hitTest(tapLocation, types: [.existingPlaneUsingGeometry])

        // If the closest of those planes is horizontal,
        // put the current furniture item on it.
        if !planeIntersections.isEmpty {
            let firstHitTestResult = planeIntersections.first!
            guard let planeAnchor = firstHitTestResult.anchor as? ARPlaneAnchor else { return }
            if planeAnchor.alignment == .horizontal {
                self.addFurniture(hitTestResult: firstHitTestResult)
            }
        }
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        self.clearAllFurniture()
    }
}
