//
//  File.swift
//  Game
//
//  Created by Julio César Guzman on 11/27/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

let π = M_PI

func random(range:UInt32) -> UInt32 {
    return arc4random_uniform(UInt32(range))
}

func ==(left: SCNVector3, right: SCNVector3) -> Bool {
    return SCNVector3EqualToVector3(left , right)
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func ·(left: SCNVector3, right: SCNVector3) -> CGFloat {
    return left.x * right.x + left.y * right.y + left.z * left.z
}

func +(left: SCNVector4, right: SCNVector4) -> SCNVector4 {
    return SCNVector4Make(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w)
}