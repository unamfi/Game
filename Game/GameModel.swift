//
//  GameLogic.swift
//  Game
//
//  Created by Julio César Guzman on 1/9/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation

protocol StatisticsDelegate {
    func didUpdateStatistics(statistics:Statistics)
}

struct Statistics {
    var delegate : StatisticsDelegate?
    var collectedPearlsCount = 0 {
        didSet {
            self.delegate?.didUpdateStatistics(self)
        }
    }
    var collectedFlowersCount = 0 {
        didSet {
            self.delegate?.didUpdateStatistics(self)
        }
    }
}


protocol GameModelCompletionDelegate  {
    func gameModelDidComplete(model:GameModel)
}

class GameModel : NSObject, StatisticsDelegate {
    
    private(set) var isComplete = false {
        didSet {
            if isComplete {
                completionDelegateMulticast.invokeDelegates({ $0.gameModelDidComplete(self) })
            }
        }
    }
    
    var statistics = Statistics()
    var completionDelegateMulticast = DelegateMulticast<GameModelCompletionDelegate>()
    var statisticsDelegateMulticast = DelegateMulticast<StatisticsDelegate>()
    
    override init() {
        super.init()
        statistics.delegate = self
    }
    
    func didUpdateStatistics(statistics: Statistics) {
        if statistics.collectedFlowersCount == 3 {
            isComplete = true
        }
        
        statisticsDelegateMulticast.invokeDelegates({ $0.didUpdateStatistics(statistics)})
    }
}