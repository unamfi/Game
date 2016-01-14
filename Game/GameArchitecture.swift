//
//  GameArchitecture.swift
//  Game
//
//  Created by Julio César Guzman on 1/12/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import SceneKit

class GameArchitecture {
    private var game : Game!
    private var sceneRendererDelegate : SceneRendererDelegate!
    
    init(model: GameModel, renderer: SCNSceneRenderer) {
        game = Game(model: model, scene: renderer.scene!, pointOfView: renderer.pointOfView!)
        sceneRendererDelegate = SceneRendererDelegate(game: game, gameModel: model)
        renderer.delegate = sceneRendererDelegate
    }
    
    func panCamera(direction: float2) {
        game.panCamera(direction)
    }
}