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
    
    var smiley : SCNNode
    var camera : SCNNode
    
    override init(scene: SCNScene, view: GameView) {
        self.smiley = scene.rootNode.childNodeWithName("smiley", recursively: true)!
        self.camera = scene.rootNode.childNodeWithName("camera", recursively: true)!
        super.init(scene: scene, view: view)
    }
    
    func performRotation () {
        let α = -self.view.α
        let ß = -self.view.ß
        
        smiley.rotation = SCNVector4Make(0.0, 1.0, 0.0, α)
        camera.rotation = SCNVector4Make(1.0, 0.0, 0.0, ß)
    }
    
    func handleKeyStrokes () {
        let θ : CGFloat = smiley.rotation.w
        var speed = CGFloat(0.05)
        let pi = CGFloat(π)
        
        self.view.handleKeyStroke("q") { () -> () in
            speed = 0.1
        }
        self.view.handleKeyStroke("w") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ) * speed
        }
        self.view.handleKeyStroke("s") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ + pi) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ + pi) * speed
        }
        self.view.handleKeyStroke("a") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ + pi / 2) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ + pi / 2) * speed
        }
        self.view.handleKeyStroke("d") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ - pi / 2) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ - pi / 2) * speed
        }
        self.view.handleKeyStroke("z") { () -> () in
            self.camera.camera?.xFov++
            self.camera.camera?.yFov++
        }
        self.view.handleKeyStroke("x") { () -> () in
            self.camera.camera?.xFov--
            self.camera.camera?.yFov--
        }
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.performRotation()
        self.handleKeyStrokes()
    }
    
}