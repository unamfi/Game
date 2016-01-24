//
//  SuperMeatBoyComponentManager.swift
//  Game
//
//  Created by Julio César Guzman on 1/23/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class ComponentManager {
    
    private weak var entity : GKEntity?
    private weak var gameModel : GameModel?
    private weak var scene : SCNScene?
    
    init(superMeatBoyEntity : GKEntity?, gameModel: GameModel, scene : SCNScene) {
        self.entity = superMeatBoyEntity
        self.gameModel = gameModel
        self.scene = scene
        setup()
    }
    
    func setup() {
        setComponents()
        putNodeOnStartingPoint()
    }
    
    func setComponents() {
        let boxModelComponent = BoxModelComponent()
        entity?.addComponent(boxModelComponent)
        entity?.addComponent(ControlComponent(controllerDirection: gameModel!.controllerDirection, node: boxModelComponent.node))
    }
    
    func putNodeOnStartingPoint() {
        let superMeatBoyNode = entity?.componentForClass(BoxModelComponent)?.node
        scene?.putNodeOnStartingPoint(superMeatBoyNode!)
    }
}