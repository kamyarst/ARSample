//
//  SCNVector3.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import SceneKit

// MARK: - SCNVector3 + Equatable

extension SCNVector3: Equatable {

    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

    func distance(from vector: SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z

        return sqrtf((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }

    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}
