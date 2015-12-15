//
//  OSXRenderer.swift
//  
//
//  Created by Julio César Guzman on 12/15/15.
//
//

import Foundation
import SceneKit

class OSXSceneRenderer : SceneRenderer
{
    var view : GameView
    
    init(scene: SCNScene, view : GameView )
    {
        self.view = view
        super.init(scene: scene)
    }
    
    override func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.view.performOnUpdate()
    }
}