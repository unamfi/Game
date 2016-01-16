//
//  CameraManipulator.swift
//  Game
//
//  Created by Julio César Guzman on 1/16/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import SceneKit

class CameraController {
    
    private var cameraModel : CameraModel!
    private var scene : SCNScene!
    private var pointOfView : SCNNode!
    
    // Nodes to manipulate the camera
    private var cameraManipulationNodes : CameraRotationNodes!
    
    init(pointOfView: SCNNode, scene: SCNScene, cameraModel: CameraModel) {
        self.pointOfView = pointOfView
        self.scene = scene
        self.cameraModel = cameraModel
        initialize()
    }
    
    private func initialize() {
        
        setupAutomaticCameraPositions()
        cameraManipulationNodes = CameraRotationNodes(pointOfView: pointOfView)
        scene.rootNode.addChildNode(cameraManipulationNodes.cameraYHandle)
        
        // Animate camera on launch and prevent the user from manipulating the camera until the end of the animation.
        SCNTransaction.animateWithDuration(completionBlock: { self.cameraModel.lockCamera = false }) {
            self.cameraModel.lockCamera = true
            self.cameraManipulationNodes.animateOnLaunch()
        }
    }
    
    func panCamera(direction : float2) {
        
        if cameraModel.lockCamera {
            return
        }
        
        cameraManipulationNodes.panCamera(direction)

    }
    
    func animateTheCameraForever() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.cameraManipulationNodes.animate()
        }
    }
    
    private var currentGround: SCNNode!
    private var mainGround: SCNNode!
    private var groundToCameraPosition = [SCNNode: SCNVector3]()
    
    private func setupAutomaticCameraPositions() {
        let rootNode = scene.rootNode
        
        mainGround = rootNode.childNodeWithName("bloc05_collisionMesh_02", recursively: true)
        
        groundToCameraPosition[rootNode.childNodeWithName("bloc04_collisionMesh_02", recursively: true)!] = SCNVector3(-0.188683, 4.719608, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc03_collisionMesh", recursively: true)!] = SCNVector3(-0.435909, 6.297167, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc07_collisionMesh", recursively: true)!] = SCNVector3( -0.333663, 7.868592, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc08_collisionMesh", recursively: true)!] = SCNVector3(-0.575011, 8.739003, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc06_collisionMesh", recursively: true)!] = SCNVector3( -1.095519, 9.425292, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc05_collisionMesh_02", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc05_collisionMesh_01", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
    }
    
    func updateCameraWithCurrentGround(groundNode: SCNNode, model: GameModel, foxCharacter :FoxCharacter) {
        if model.isWin() {
            return
        }
        
        if currentGround == nil {
            currentGround = groundNode
            return
        }
        
        let characterNode = foxCharacter.node
        updateThePositionOfTheCameraWhenWeMoveToAnotherBlock(characterNode, groundNode: groundNode)
    }
    
    private func updateThePositionOfTheCameraWhenWeMoveToAnotherBlock(characterNode : SCNNode, groundNode: SCNNode) {
        if groundNode != currentGround {
            currentGround = groundNode
            
            if var position = groundToCameraPosition[groundNode] {
                if groundNode == mainGround && characterNode.position.x < 2.5 {
                    position = SCNVector3(-0.098175, 3.926991, 0.0)
                }
                cameraManipulationNodes.updateCameraPosition(position)
            }
        }
    }
}