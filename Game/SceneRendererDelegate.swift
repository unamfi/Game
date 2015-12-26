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

// MARK: SCNSceneRendererDelegate Conformance (Game Loop)

// SceneKit calls this method exactly once per frame, so long as the SCNView object (or other SCNSceneRenderer object) displaying the scene is not paused.
// Implement this method to add game logic to the rendering loop. Any changes you make to the scene graph during this method are immediately reflected in the displayed scene.

class SceneRendererDelegate : NSObject, SCNSceneRendererDelegate {

    private var scene : SCNScene
    private var characterDirection : () -> float3
    private var character : Character
    private var updateCameraWithCurrentGround : SCNNode -> ()
    private var flames : [SCNNode]
    private var enemies : [SCNNode]
    private var game : Game
    private var flameThrowerSound : SCNAudioPlayer!
    
    init(                scene : SCNScene, // Game candidate
            characterDirection : () -> float3,
                     character : Character,
 updateCameraWithCurrentGround : SCNNode -> (),
                        flames : [SCNNode],
                       enemies : [SCNNode],
                          game : Game,
             flameThrowerSound : SCNAudioPlayer!) {
          
            self.scene = scene
            self.characterDirection = characterDirection
            self.character = character
            self.updateCameraWithCurrentGround = updateCameraWithCurrentGround
            self.flames = flames
            self.enemies = enemies
            self.game = game
            self.flameThrowerSound = flameThrowerSound
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
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        // Reset some states every frame
        self.character.replacementPosition = nil
        self.character.maxPenetrationDistance = 0
        
        let scene = self.scene
        let direction = characterDirection()
        
        let groundNode = character.walkInDirection(direction, time: time, scene: scene, groundTypeFromMaterial:groundTypeFromMaterial)
        if let groundNode = groundNode {
            updateCameraWithCurrentGround(groundNode)
        }
        
        // Flames are static physics bodies, but they are moved by an action - So we need to tell the physics engine that the transforms did change.
        for flame in flames {
            flame.physicsBody!.resetTransform()
        }
        
        // Adjust the volume of the enemy based on the distance to the character.
        var distanceToClosestEnemy = Float.infinity
        let characterPosition = float3(character.node.position)
        for enemy in enemies {
            //distance to enemy
            let enemyTransform = float4x4(enemy.worldTransform)
            let enemyPosition = float3(enemyTransform[3].x, enemyTransform[3].y, enemyTransform[3].z)
            let distance = simd.distance(characterPosition, enemyPosition)
            distanceToClosestEnemy = min(distanceToClosestEnemy, distance)
        }
        
        // Adjust sounds volumes based on distance with the enemy.
        if !self.game.isComplete {
            if let mixer = flameThrowerSound!.audioNode as? AVAudioMixerNode {
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
}