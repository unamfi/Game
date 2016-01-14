/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This class manages most of the game logic.
*/

import simd
import QuartzCore
import GameController

#if os(iOS) || os(tvOS)
    typealias ViewController = UIViewController
#elseif os(OSX)
    typealias ViewController = NSViewController
#endif

class GameViewController: ViewController {

    var gameView: GameView {
        return view as! GameView
    }
    
    var gameModel = GameModel()
    
    // Game controls
    internal var controllerDPad: GCControllerDirectionPad?
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    
    #if os(OSX)
    internal var lastMousePosition = float2(0)
    #elseif os(iOS)
    internal var padTouch: UITouch?
    internal var panningTouch: UITouch?
    #endif
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameModel.controllerDirection = controllerDirection
        gameView.setup(gameModel)
        
        setupGameControllers()
    }

    
    func panCamera(var direction: float2) {
        
        #if os(iOS) || os(tvOS)
            direction *= float2(1.0, -1.0)
        #endif
    
        gameView.panCamera(direction)
    }
    
}
