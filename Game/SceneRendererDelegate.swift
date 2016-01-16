//
//  SceneRenderer.swift
//  Game
//
//  Created by Julio César Guzman on 12/25/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

class SceneRendererDelegate : NSObject, SCNSceneRendererDelegate {

    private var game : Game
    
    init(game : Game) {
        self.game = game
        super.init()
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        game.updateGameAtTime(time)
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        game.didSimulatePhysicsOfGameAtTime(time)
    }
}