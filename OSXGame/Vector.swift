//
//  Vector.swift
//  Game
//
//  Created by Julio César Guzman on 12/15/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

func ==(left: SCNVector3, right: SCNVector3) -> Bool {
    return SCNVector3EqualToVector3(left , right)
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func *(left: SCNVector3, right: SCNVector3) -> SCNFloat {
    return left.x * right.x + left.y * right.y + left.z * right.z
}

func *(left: SCNFloat, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left * right.x , left * right.y, left * right.z)
}

func ^(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    let i = left.y * right.z - left.z * right.y
    let j = left.z * right.x - left.x * right.z
    let k = left.x * right.y - left.y * right.x
    return SCNVector3Make(i, j, k)
}

func +(left: SCNVector4, right: SCNVector4) -> SCNVector4 {
    return SCNVector4Make(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w)
}

func normalize(vector: SCNVector3) -> SCNVector3 {
    let magnitude = magnitudeOf(vector)
    return SCNVector3Make(vector.x / magnitude, vector.y / magnitude, vector.z / magnitude)
}

func magnitudeOf(vector: SCNVector3) -> SCNFloat {
    return sqrt(vector.x * vector.x  + vector.y * vector.y + vector.z * vector.z);
}

func angleBetween(vectorA: SCNVector3, vectorB: SCNVector3) -> SCNFloat {
    let ab = vectorA * vectorB
    let abmodules = magnitudeOf(vectorA) * magnitudeOf(vectorB)
    let result = acos(ab/abmodules)
    if result.isNaN {
        return SCNFloat(π)/2
    }
    return result
}
