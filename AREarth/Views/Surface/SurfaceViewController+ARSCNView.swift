//
//  SurfaceViewController+ARSCNView.swift
//  AREarth
//
//  Created by Kamyar Sehati on 10/14/21.
//

import ARKit

// MARK: - SurfaceViewController + ARSCNViewDelegate

extension SurfaceViewController: ARSCNViewDelegate {

    // This method is called once per frame, and we use it to perform tasks
    // that we want performed constantly.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        DispatchQueue.main.async {
            self.viewModel.updateAppState(for: self.view, sceneView: self.sceneView)
        }
    }

    // This delegate method gets called whenever the node corresponding to
    // an existing AR anchor is removed.
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // We only want to deal with plane anchors.
        guard anchor is ARPlaneAnchor else { return }

        // Remove any children this node may have.
        node.enumerateChildNodes { childNode, _ in
            childNode.removeFromParentNode()
        }
    }

    // This delegate method gets called whenever the node correspondinf to
    // an existing AR anchor is updated.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Once again, we only want to deal with plane anchors.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Remove any children this node may have.
        node.enumerateChildNodes { childNode, _ in
            childNode.removeFromParentNode()
        }

        // Update the plane over this surface.
        self.viewModel.drawPlaneNode(on: node, for: planeAnchor)
    }

    // This delegate method gets called whenever the node corresponding to
    // a new AR anchor is added to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // We only want to deal with plane anchors, which encapsulate
        // the position, orientation, and size, of a detected surface.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Draw the appropriate plane over the detected surface.
        self.viewModel.drawPlaneNode(on: node, for: planeAnchor)
    }

    // Update the status text at the top of the screen whenever
    // the AR camera tracking state changes.
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

        switch camera.trackingState {
        case .notAvailable:
            self.searchImage.tintColor = .red
        case .normal:
            self.searchImage.tintColor = .green
        case let .limited(reason):
            switch reason {
            case .excessiveMotion:
                self.searchImage.tintColor = .yellow
            case .insufficientFeatures:
                self.searchImage.tintColor = .yellow
            case .initializing:
                self.searchImage.tintColor = .yellow
            case .relocalizing:
                self.searchImage.tintColor = .yellow
            }
        }
    }
}

// MARK: - AR session error management

extension SurfaceViewController {

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        self.searchImage.tintColor = .red
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        self.searchImage.tintColor = .red
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        self.searchImage.tintColor = .red
        self.resetARsession()
    }
}
