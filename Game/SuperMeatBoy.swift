//
//  Entities.swift
//  Game
//
//  Created by Julio César Guzman on 1/20/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class SuperMeatBoy {
    let entity = GKEntity()
    
    init(gameModel : GameModel, scene: SCNScene) {
        entity.addComponent(NodeComponent())
        entity.addComponent(CollissionComponent())
        entity.addComponent(PlayerComponent(scene: scene))
        entity.addComponent(ControlComponent(controllerDirection: gameModel.controllerDirection))
    }
    
}