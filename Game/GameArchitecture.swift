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
    private var gameModel = GameModel()
    private var sceneRendererDelegate : SceneRendererDelegate!
    private var controllerDirection: ()->float2 = { return float2() }
    
    func setup(gameView: GameView, controllerDirection: ()->float2 ) {
        
        self.controllerDirection = controllerDirection
        
        game = Game(gameModel: gameModel, controllerDirection: controllerDirection)
        gameView.scene = game.scene
        game.pointOfView = gameView.pointOfView
        game.setupAfterSceneAndPointOfViewHaveBeenSet()
        
        gameModel.addDelegates([game, gameView])
        
        setupSceneRendererDelegateOnRenderer(game, sceneRenderer: gameView)
        
    }
    
    private func setupSceneRendererDelegateOnRenderer(game: Game, sceneRenderer : SCNSceneRenderer) {
        sceneRendererDelegate = SceneRendererDelegate(game: game, controllerDirection: controllerDirection)
        sceneRenderer.delegate = sceneRendererDelegate
    }
    
    func panCamera(direction: float2) {
        game.panCamera(direction)
    }
    
}
