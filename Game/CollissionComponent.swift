//
//  CollissionComponent.swift
//  Game
//
//  Created by Julio César Guzman on 1/30/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

class CollissionComponent : GKComponent
{
    override init() {
        super.init()
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        let nodeComponent = entity?.componentForClass(NodeComponent)
        let node = nodeComponent?.node
        let physicsBody = node?.physicsBody
        
        if physicsBody == nil && node != nil {
            addPhysicsBodyToNode(node!)
            physicsBody?.collisionBitMask = BitmaskCollision
        }
       
    }
    
    private func addPhysicsBodyToNode(node : SCNNode) {
        let shape = SCNPhysicsShape(node: node, options: nil)
        let physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: shape)
        node.physicsBody?.collisionBitMask = BitmaskCollision
        node.physicsBody = physicsBody
    }
}