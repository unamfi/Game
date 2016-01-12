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
        setupGameArchitecture()
    }
    
    // MARK: Architecture
    var gameView: GameView {
        return view as! GameView
    }
    
    private var game : Game!
    private var gameModel = GameModel()
    private var sceneRendererDelegate : SceneRendererDelegate!
    
    func setupGameArchitecture() {
        
        game = Game(gameModel: gameModel, controllerDirection: self.controllerDirection)
        gameView.scene = game.scene
        game.pointOfView = gameView.pointOfView
        game.setupAfterSceneAndPointOfViewHaveBeenSet()
        
        gameModel.addDelegates([game, gameView])
        
        
        setupSceneRendererDelegateOnRenderer(game, sceneRenderer: gameView)
        setupGameControllers()
    }
    
    // MARK: Scene Renderer Delegate

    private func setupSceneRendererDelegateOnRenderer(game: Game, sceneRenderer : SCNSceneRenderer) {
        sceneRendererDelegate = SceneRendererDelegate(game: game, controllerDirection: controllerDirection)
        sceneRenderer.delegate = sceneRendererDelegate
    }
    
    func panCamera(var direction: float2) {
        
        #if os(iOS) || os(tvOS)
            direction *= float2(1.0, -1.0)
        #endif
    
        game.panCamera(direction)
    }
    
}
