//
//  Gameplay.swift
//  Game
//
//  Created by Julio César Guzman on 12/20/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import GameplayKit

class PlayerModel: NSObject, GKGameModelPlayer {
    var playerId = 0
}

class CollectedPearlsUpdate : NSObject, GKGameModelUpdate {
    var value = 0
}

class CollectedFlowersUpdate : NSObject, GKGameModelUpdate {
    var value = 0
}

protocol GameModelDelegate {
    func didApplyGameModelUpdate(gameModel:GameModel)
}

class GameModel:NSObject, NSCopying, GKGameModel {
    
    var players : [GKGameModelPlayer]?
    var activePlayer : GKGameModelPlayer?
    
    var sceneName = "game.scnassets/level.scn"
    var playerModel = PlayerModel()
    var collectedPearlsUpdate = CollectedPearlsUpdate()
    var collectedFlowersUpdate = CollectedFlowersUpdate()
    var delegates = MulticastDelegate<GameModelDelegate>()
    
    var controllerDirection: ()->float2 = { return float2() }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self
    }
    
    func setGameModel(gameModel: GKGameModel) {
        
    }
    
    func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        return []
    }
    
    func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        if gameModelUpdate is CollectedFlowersUpdate ||
           gameModelUpdate is CollectedPearlsUpdate {
           gameModelUpdate.value++
        }
        delegates.invokeDelegates({ (delegate) -> () in
            delegate.didApplyGameModelUpdate(self)
        })
    }
    
    func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        return collectedFlowersUpdate.value
    }
    
    func isWinForPlayer(player: GKGameModelPlayer) -> Bool {
        return collectedFlowersUpdate.value == 3
    }
}

extension GameModel {
    func addDelegates(delegates : [GameModelDelegate]) {
        for delegate in delegates {
            self.delegates.addDelegate(delegate)
        }
    }
}

extension GameModel {
    
    func applyCollectedPearlsUpdate() {
        applyGameModelUpdate(collectedPearlsUpdate)
    }
    
    func applyCollectedFlowersUpdate() {
        applyGameModelUpdate(collectedFlowersUpdate)
    }

}

extension GameModel {
    
    func isWin() -> Bool {
        return isWinForPlayer(playerModel)
    }
    
}