//
//  SuperMeatBoyComponent.swift
//  Game
//
//  Created by Julio César Guzman on 1/20/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

class PlayerComponent: GKComponent {

    private weak var scene : SCNScene?
    
    init(scene: SCNScene) {
        super.init()
        self.scene = scene
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        let nodeComponent = self.entity?.componentForClass(NodeComponent)
        if nodeComponent?.node == nil {
            nodeComponent?.node = scene!.rootNode.childNodeWithName("player", recursively: true)
        }
    }
}