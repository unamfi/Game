//
//  ControlComponent.swift
//  Game
//
//  Created by Julio César Guzman on 1/20/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit


class ControlComponent: GKComponent {
    
    private let speed = Float(0.000001)
    private var controllerDirection = { () in return float2() }
    private var node : SCNNode!
    
    init(controllerDirection: ()->float2) {
        super.init()
        self.controllerDirection = controllerDirection
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if node == nil {
            getNodeFromComponent()
        }

        jump()
        setAngularVelocityToZero()
        changePositionWithDeltaTime(seconds)
    }
    
    private func changePositionWithDeltaTime(seconds: NSTimeInterval) {
        
        let direction = float3(-controllerDirection().x,0.0,0.0)
        let deltaTime = Float(seconds)
        let deltaX = deltaTime * speed
        let position = float3(node.position)
        node.position = SCNVector3(position + direction * deltaX)
    }
    
    private func setAngularVelocityToZero() {
        node.physicsBody?.angularVelocity = SCNVector4Make(0.0, 0.0, 0.0, 0.0)
    }
    
    private func jump() {
        if controllerDirection().y != 0.0 {
            let up = SCNVector3(0.0, 1.0, 0.0)
            node.physicsBody?.applyForce(up, impulse: true)
        }
    }
    
    private func getNodeFromComponent() {
        node = self.entity!.componentForClass(NodeComponent)!.node!
    }
    
}