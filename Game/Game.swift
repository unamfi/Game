//
//  Game.swift
//  Game
//
//  Created by Julio César Guzman on 12/26/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

class Game: NSObject {
    var isComplete = false
    
    var scene : SCNScene!
    
    var grassArea: SCNMaterial!
    var waterArea: SCNMaterial!
    
    var flames = [SCNNode]()
    var enemies = [SCNNode]()
    
    var collectPearlSound: SCNAudioSource!
    var collectFlowerSound: SCNAudioSource!
    var flameThrowerSound: SCNAudioPlayer!
    var victoryMusic: SCNAudioSource!
    
    var currentGround: SCNNode!
    var mainGround: SCNNode!
    var groundToCameraPosition = [SCNNode: SCNVector3]()
    
    // Particles
    var confettiParticleSystem: SCNParticleSystem!
    var collectFlowerParticleSystem: SCNParticleSystem!
    
    // Nodes to manipulate the camera
    let cameraYHandle = SCNNode()
    let cameraXHandle = SCNNode()
    
    let character = Character()
    
    var gameView : GameView!
    
    init(gameView: GameView) {
        super.init()
        self.gameView = gameView
        self.scene = gameView.scene
        self.setupAutomaticCameraPositions()
    }
    
    private func setupAutomaticCameraPositions() {
        let rootNode = self.scene.rootNode
        
        mainGround = rootNode.childNodeWithName("bloc05_collisionMesh_02", recursively: true)
        
        groundToCameraPosition[rootNode.childNodeWithName("bloc04_collisionMesh_02", recursively: true)!] = SCNVector3(-0.188683, 4.719608, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc03_collisionMesh", recursively: true)!] = SCNVector3(-0.435909, 6.297167, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc07_collisionMesh", recursively: true)!] = SCNVector3( -0.333663, 7.868592, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc08_collisionMesh", recursively: true)!] = SCNVector3(-0.575011, 8.739003, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc06_collisionMesh", recursively: true)!] = SCNVector3( -1.095519, 9.425292, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc05_collisionMesh_02", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc05_collisionMesh_01", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
    }
    
    
    func updateCameraWithCurrentGround(node: SCNNode) {
        if isComplete {
            return
        }
        
        if currentGround == nil {
            currentGround = node
            return
        }
        
        // Automatically update the position of the camera when we move to another block.
        if node != currentGround {
            currentGround = node
            
            if var position = groundToCameraPosition[node] {
                if node == mainGround && character.node.position.x < 2.5 {
                    position = SCNVector3(-0.098175, 3.926991, 0.0)
                }
                
                let actionY = SCNAction.rotateToX(0, y: CGFloat(position.y), z: 0, duration: 3.0, shortestUnitArc: true)
                actionY.timingMode = SCNActionTimingMode.EaseInEaseOut
                
                let actionX = SCNAction.rotateToX(CGFloat(position.x), y: 0, z: 0, duration: 3.0, shortestUnitArc: true)
                actionX.timingMode = SCNActionTimingMode.EaseInEaseOut
                
                cameraYHandle.runAction(actionY)
                cameraXHandle.runAction(actionX)
            }
        }
    }
    
    func characterDirection(controllerDirection : float2) -> float3 {
        
        var direction = float3(controllerDirection.x, 0.0, controllerDirection.y)
        
        if let pov = self.gameView.pointOfView {
            let p1 = pov.presentationNode.convertPosition(SCNVector3(direction), toNode: nil)
            let p0 = pov.presentationNode.convertPosition(SCNVector3Zero, toNode: nil)
            direction = float3(Float(p1.x - p0.x), 0.0, Float(p1.z - p0.z))
            
            if direction.x != 0.0 || direction.z != 0.0 {
                direction = normalize(direction)
            }
        }
        
        return direction
    }
    
    
}