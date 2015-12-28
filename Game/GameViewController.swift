/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This class manages most of the game logic.
*/

import simd
import SceneKit
import SpriteKit
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
    
    private var game : Game!
    
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
        
        let scene = SCNScene(named: "game.scnassets/level.scn")!
        
        gameView.setup(scene)
        
        game = Game(gameView: gameView)
        
        // Setup delegates
        gameView.physicsContactDelegate = PhysicsContactDelegate(game: game)
        scene.physicsWorld.contactDelegate = gameView.physicsContactDelegate
        gameView.sceneRendererDelegate = SceneRendererDelegate(game: game, controllerDirection: controllerDirection)
        gameView.delegate = gameView.sceneRendererDelegate
        
       
        setupGameControllers()
    }
    
    func panCamera(var direction: float2) {
        
        #if os(iOS) || os(tvOS)
            direction *= float2(1.0, -1.0)
        #endif
    
        self.game.panCamera(direction)
    }
    
}
