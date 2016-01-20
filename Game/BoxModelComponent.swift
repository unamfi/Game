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

class BoxModelComponent: GKComponent {
    var node : SCNNode!
    override init() {
        super.init()
        self.node = SCNScene(named: "game.scnassets/box.scn")!.rootNode.childNodes[0]
    }
}