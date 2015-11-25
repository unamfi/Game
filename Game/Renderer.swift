//
//  File.swift
//  Game
//
//  Created by Julio César Guzman on 11/22/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

func ==(left: SCNVector3, right: SCNVector3) -> Bool {
    return SCNVector3EqualToVector3(left , right)
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func +(left: SCNVector4, right: SCNVector4) -> SCNVector4 {
    return SCNVector4Make(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w)
}

class SceneRenderer: NSObject, SCNSceneRendererDelegate {
    
    var scene : SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
    }
}

class PracticaSceneRenderer : SceneRenderer
{
    
    var lastTime : NSTimeInterval = NSTimeInterval()
    var currentTime : NSTimeInterval = NSTimeInterval()
    
    override init(scene: SCNScene) {
        super.init(scene: scene)

    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        let deltaTime = time - lastTime;
        let t = time + deltaTime
        
        currentTime = t
        
        lastTime = time
    }
    
}