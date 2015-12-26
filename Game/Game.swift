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
    
    // Nodes to manipulate the camera
    let cameraYHandle = SCNNode()
    let cameraXHandle = SCNNode()
    
    init(scene: SCNScene) {
        super.init()
        self.scene = scene
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
}