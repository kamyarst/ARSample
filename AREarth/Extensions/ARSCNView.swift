//
//  ARSCNView.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import ARKit

extension ARSCNView {

    func realWorldVector(screenPos: CGPoint) -> SCNVector3? {

        let planeTestResults = self.hitTest(screenPos, types: [.featurePoint])
        if let result = planeTestResults.first {
            return SCNVector3.positionFromTransform(result.worldTransform)
        }

        return nil
    }
}
