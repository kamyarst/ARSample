//
//  EarthViewModel.swift
//  AREarth
//
//  Created by Kamyar Sehati on 10/14/21.
//

import ARKit
import SceneKit

final class EarthViewModel {

    private(set) var node = SCNNode()

    func buildWholeWorld() {

        self.buildEarth()
        self.buildShip()
        self.addAnimationToShip()
    }

    func getARConfiguration() -> ARConfiguration {
        ARWorldTrackingConfiguration()
    }

    private func buildEarth() {

        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: "earth.jpg")
        sphere.firstMaterial?.specular.contents = UIColor.yellow
        let node = SCNNode(geometry: sphere)
        self.node.addChildNode(node)
    }

    private func buildShip() {

        guard let ship = SCNScene(named: "art.scnassets/ship.scn")?
            .rootNode.childNode(withName: "ship", recursively: false)
        else { return }
        ship.position = SCNVector3(x: 1, y: 0, z: 0)
        ship.scale = SCNVector3(x: 0.3, y: 0.3, z: 0.3)
        ship.eulerAngles = SCNVector3(0, 180.toRadius, 0)
        self.node.addChildNode(ship)
    }

    // MARK: - Function

    private func addAnimationToShip() {

        let rotateAnimation = SCNAction.rotate(by: 360.toRadius,
                                               around: SCNVector3(x: 0, y: 1, z: 0),
                                               duration: 8)
        let rotateForEver = SCNAction.repeatForever(rotateAnimation)
        self.node.runAction(rotateForEver)
    }
}
