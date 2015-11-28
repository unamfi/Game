//
//  File.swift
//  Game
//
//  Created by Julio César Guzman on 11/22/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

class SceneRenderer: NSObject, SCNSceneRendererDelegate {
    
    var scene : SCNScene
    var view : GameView
    
    init(scene: SCNScene, view: GameView) {
        self.scene = scene
        self.view = view
    }
}

class UpdateSceneRenderer : SceneRenderer {
    
    var lastTime : NSTimeInterval = NSTimeInterval()
    var currentTime : NSTimeInterval = NSTimeInterval()
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        let deltaTime = time - lastTime;
        let t = time + deltaTime
        
        currentTime = t
        lastTime = time
    }
}

class PracticaSceneRenderer : SceneRenderer
{
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.view.performOnUpdate()
    }
}