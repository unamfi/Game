//
//  ControlComponent.swift
//  Game
//
//  Created by Julio César Guzman on 1/20/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

class ControlComponent: GKComponent {
    
    private var controllerDirection = { () in return float2()}
    private weak var node : SCNNode?
    
    init(controllerDirection: ()->float2, node : SCNNode) {
        super.init()
        self.node = node
        self.controllerDirection = controllerDirection
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {

    }
}