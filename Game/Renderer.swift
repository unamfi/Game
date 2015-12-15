//
//  File.swift
//  Game
//
//  Created by Julio César Guzman on 11/22/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

class SceneRenderer : NSObject, SCNSceneRendererDelegate {
    var scene : SCNScene

    var lastTime : NSTimeInterval = NSTimeInterval()
    var currentTime : NSTimeInterval = NSTimeInterval()
    
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        let deltaTime = time - lastTime;
        let t = time + deltaTime
        
        currentTime = t
        lastTime = time
    }
}

