//
//  SceneRenderer.swift
//  Game
//
//  Created by Julio César Guzman on 12/25/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class SceneRendererDelegate : NSObject, SCNSceneRendererDelegate {

    private var controllerDirection : () -> float2
    private var character : Character
    private var updateCameraWithCurrentGround : SCNNode -> ()
    private var game : Game
    private var gameView : GameView
    
    init(            character : Character,
 updateCameraWithCurrentGround : SCNNode -> (),
                          game : Game,
                      gameView : GameView,
           controllerDirection : () -> float2) {
        self.controllerDirection = controllerDirection
        self.character = character
        self.updateCameraWithCurrentGround = updateCameraWithCurrentGround
        self.game = game
        self.gameView = gameView
        super.init()
    }
    
    private func groundTypeFromMaterial(material: SCNMaterial) -> GroundType {
        if material == self.game.grassArea {
            return .Grass
        }
        if material == self.game.waterArea {
            return .Water
        }
        else {
            return .Rock
        }
    }
    
    // SceneKit calls this method exactly once per frame, so long as the SCNView object (or other SCNSceneRenderer object) displaying the scene is not paused.
    // Implement this method to add game logic to the rendering loop. Any changes you make to the scene graph during this method are immediately reflected in the displayed scene.
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        // Reset some states every frame
        self.character.replacementPosition = nil
        self.character.maxPenetrationDistance = 0
        
        let scene = self.game.scene
        let direction = characterDirection()
        
        let groundNode = character.walkInDirection(direction, time: time, scene: scene, groundTypeFromMaterial:groundTypeFromMaterial)
        if let groundNode = groundNode {
            updateCameraWithCurrentGround(groundNode)
        }
        
        // Flames are static physics bodies, but they are moved by an action - So we need to tell the physics engine that the transforms did change.
        for flame in self.game.flames {
            flame.physicsBody!.resetTransform()
        }
        
        // Adjust the volume of the enemy based on the distance to the character.
        var distanceToClosestEnemy = Float.infinity
        let characterPosition = float3(character.node.position)
        for enemy in self.game.enemies {
            //distance to enemy
            let enemyTransform = float4x4(enemy.worldTransform)
            let enemyPosition = float3(enemyTransform[3].x, enemyTransform[3].y, enemyTransform[3].z)
            let distance = simd.distance(characterPosition, enemyPosition)
            distanceToClosestEnemy = min(distanceToClosestEnemy, distance)
        }
        
        // Adjust sounds volumes based on distance with the enemy.
        if !self.game.isComplete {
            if let mixer = self.game.flameThrowerSound!.audioNode as? AVAudioMixerNode {
                mixer.volume = 0.3 * max(0, min(1, 1 - ((distanceToClosestEnemy - 1.2) / 1.6)))
            }
        }
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // If we hit a wall, position needs to be adjusted
        if let position = self.character.replacementPosition {
            character.node.position = position
        }
    }
    
    // MARK: Moving the Character
    
    private func characterDirection() -> float3 {
        let controllerDirection = self.controllerDirection()
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