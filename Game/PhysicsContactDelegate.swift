//
//  PhysicsContactDelegate.swift
//  Game
//
//  Created by Julio César Guzman on 12/26/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

// Collision bit masks
let BitmaskCollision        = 1 << 2
let BitmaskCollectable      = 1 << 3
let BitmaskEnemy            = 1 << 4
let BitmaskSuperCollectable = 1 << 5
let BitmaskWater            = 1 << 6

class PhysicsContactDelegate: NSObject, SCNPhysicsContactDelegate {

    private var game : Game!
    
    init(game : Game) {
        super.init()
        self.game = game
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        contact.match(category: BitmaskCollision) { (matching, other) in
            self.game.foxCharacter.characterNode(other, hitWall: matching, withContact: contact)
        }
        contact.match(category: BitmaskCollectable) { (matching, _) in
            self.game.collectPearl(matching)
        }
        contact.match(category: BitmaskSuperCollectable) { (matching, _) in
            self.game.collectFlower(matching)
        }
        contact.match(category: BitmaskEnemy) { (_, _) in
            self.game.foxCharacter.catchTailOnFire()
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        contact.match(category: BitmaskCollision) { (matching, other) in
            self.game.foxCharacter.characterNode(other, hitWall: matching, withContact: contact)
        }
    }
    
}