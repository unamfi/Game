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
    private var game : Game
    
    init(game : Game, controllerDirection : () -> float2) {
        self.controllerDirection = controllerDirection
        self.game = game
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
        
        let character = game.character
        
        // Reset some states every frame
        character.replacementPosition = nil
        character.maxPenetrationDistance = 0
        
        let scene = self.game.scene
        let controllerDirection = self.controllerDirection()
        let direction = self.game.characterDirection(controllerDirection)
        
        let groundNode = character.walkInDirection(direction, time: time, scene: scene, groundTypeFromMaterial:groundTypeFromMaterial)
        if let groundNode = groundNode {
            game.updateCameraWithCurrentGround(groundNode)
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
        if !self.game.logic.isComplete {
            if let mixer = self.game.flameThrowerSound!.audioNode as? AVAudioMixerNode {
                mixer.volume = 0.3 * max(0, min(1, 1 - ((distanceToClosestEnemy - 1.2) / 1.6)))
            }
        }
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // If we hit a wall, position needs to be adjusted
        let character = game.character
        if let position = character.replacementPosition {
            character.node.position = position
        }
    }

}