//
//  SurfaceViewModel.swift
//  AREarth
//
//  Created by Kamyar Sehati on 10/14/21.
//

import ARKit
import Combine
import SceneKit

final class SurfaceViewModel {

    private(set) var node = SCNNode()
    @Published var appState: AppState = .lookingForSurface

    func getARConfiguration() -> ARWorldTrackingConfiguration {

        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity // Sets Y-axis to be parallel to gravity.
        config.planeDetection = [.horizontal, .vertical] // Detect horizontal *and* vertical planes.
        config.isLightEstimationEnabled = true
        config.providesAudioData = false
        return config
    }

    func drawPlaneNode(on node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        // Create a plane node with the same position and size
        // as the detected plane.
        let planeNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                                   height: CGFloat(planeAnchor.extent.z)))
        planeNode.position = SCNVector3(planeAnchor.center.x,
                                        planeAnchor.center.y,
                                        planeAnchor.center.z)
        planeNode.geometry?.firstMaterial?.isDoubleSided = true

        // Align the plane with the anchor.
        planeNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, 0)

        // Give the plane node the appropriate surface.
        if planeAnchor.alignment == .horizontal {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
            planeNode.name = "horizontal"
        } else {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
            planeNode.name = "vertical"
        }

        // Add the plane node to the scene.
        node.addChildNode(planeNode)
        self.appState = .readyToFurnish
    }
    
    // We can’t check *every* point in the view to see if it contains one of
    // the detected planes. Instead, we assume that the planes that will be detected
    // will intersect with at least one point on a 5*5 grid spanning the entire view.
   private  func isAnyPlaneInView(for view: UIView, sceneView: ARSCNView) -> Bool {
        let screenDivisions = 5 - 1
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        for y in 0 ... screenDivisions {
            let yCoord = CGFloat(y) / CGFloat(screenDivisions) * viewHeight
            for x in 0 ... screenDivisions {
                let xCoord = CGFloat(x) / CGFloat(screenDivisions) * viewWidth
                let point = CGPoint(x: xCoord, y: yCoord)
                
                // Perform hit test for planes.
                let hitTest = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
                if !hitTest.isEmpty {
                    return true
                }
            }
        }
        return false
    }
    
    // Updates the app status, based on whether any of the detected planes
    // are currently in view.
    func updateAppState(for view: UIView, sceneView: ARSCNView) {
        guard self.appState == .pointToSurface ||
                self.appState == .readyToFurnish
        else {
            return
        }
        
        if self.isAnyPlaneInView(for :view, sceneView: sceneView) {
            self.appState = .readyToFurnish
        } else {
            self.appState = .pointToSurface
        }
    }

    enum AppState: Int16 {
        case lookingForSurface // Just starting out; no surfaces detected yet
        case pointToSurface // Surfaces detected, but device is not pointing to any of them
        case readyToFurnish // Surfaces detected *and* device is pointing to at least one
    }
}
