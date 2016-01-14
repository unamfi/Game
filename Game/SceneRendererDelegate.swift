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

    private var gameModel : GameModel
    private var game : Game
    
    init(game : Game, gameModel: GameModel) {
        self.gameModel = gameModel
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
        
        let foxCharacter = game.foxCharacter
        
        // Reset some states every frame
        foxCharacter.replacementPosition = nil
        foxCharacter.maxPenetrationDistance = 0
        
        let scene = game.scene
        let controllerDirection = gameModel.controllerDirection()
        let direction = game.characterDirection(controllerDirection)
        
        let groundNode = foxCharacter.walkInDirection(direction, time: time, scene: scene, groundTypeFromMaterial:groundTypeFromMaterial)
        if let groundNode = groundNode {
            game.updateCameraWithCurrentGround(groundNode)
        }
        
        // Flames are static physics bodies, but they are moved by an action - So we need to tell the physics engine that the transforms did change.
        for flame in game.flames {
            flame.physicsBody!.resetTransform()
        }
        
        // Adjust the volume of the enemy based on the distance to the character.
        var distanceToClosestEnemy = Float.infinity
        let characterPosition = float3(foxCharacter.node.position)
        for enemy in self.game.enemies {
            //distance to enemy
            let enemyTransform = float4x4(enemy.worldTransform)
            let enemyPosition = float3(enemyTransform[3].x, enemyTransform[3].y, enemyTransform[3].z)
            let distance = simd.distance(characterPosition, enemyPosition)
            distanceToClosestEnemy = min(distanceToClosestEnemy, distance)
        }
        
        // Adjust sounds volumes based on distance with the enemy.
        if !game.model.isWin() {
            if let mixer = self.game.flameThrowerSound!.audioNode as? AVAudioMixerNode {
                mixer.volume = 0.3 * max(0, min(1, 1 - ((distanceToClosestEnemy - 1.2) / 1.6)))
            }
        }
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // If we hit a wall, position needs to be adjusted
        let foxCharacter = game.foxCharacter
        if let position = foxCharacter.replacementPosition {
            foxCharacter.node.position = position
        }
    }

}