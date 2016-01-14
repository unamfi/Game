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
    private var gamemodel = GameModel()
    private var gameView : GameView?
    private var sceneRendererDelegate : SceneRendererDelegate!
    
    func setup(gameView: GameView, controllerDirection: ()->float2 ) {
        
        self.gameView = gameView
        
        game = Game(gameModel: gamemodel)
        gameView.scene = game.scene
        game.pointOfView = gameView.pointOfView
        game.setupAfterSceneAndPointOfViewHaveBeenSet()
        
        gamemodel.controllerDirection = controllerDirection
        gamemodel.addDelegates([game, gameView])
    
        sceneRendererDelegate = SceneRendererDelegate(game: game, gameModel: gamemodel)
        gameView.delegate = sceneRendererDelegate
    }

    func panCamera(direction: float2) {
        game.panCamera(direction)
    }
    
}
