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

class GameViewController: ViewController, SCNPhysicsContactDelegate {
   
    // Game view
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
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new scene.
        let scene = SCNScene(named: "game.scnassets/level.scn")!
        
        // Set the scene to the view and loop for the animation of the bamboos.
        gameView.scene = scene
        gameView.playing = true
        gameView.loops = true
        
        // Set the game component
        game = Game(gameView: gameView)
        game.setupCamera()
        game.setupSounds()
        game.collectFlowerParticleSystem = SCNParticleSystem(named: "collect.scnp", inDirectory: nil)
        game.collectFlowerParticleSystem.loops = false
        game.confettiParticleSystem = SCNParticleSystem(named: "confetti.scnp", inDirectory: nil)
        
        // Add the character to the scene.
        scene.rootNode.addChildNode(game.character.node)
        
        let startPosition = scene.rootNode.childNodeWithName("startingPoint", recursively: true)!
        game.character.node.transform = startPosition.transform
        
        // Retrieve various game elements in one traversal
        var collisionNodes = [SCNNode]()
        scene.rootNode.enumerateChildNodesUsingBlock { (node, _) in
            switch node.name {
            case .Some("flame"):
                node.physicsBody!.categoryBitMask = BitmaskEnemy
                self.game.flames.append(node)
            case .Some("enemy"):
                self.game.enemies.append(node)
            case let .Some(s) where s.rangeOfString("collision") != nil:
                collisionNodes.append(node)
            default:
                break
            }
        }
        
        for node in collisionNodes {
            node.hidden = false
            game.setupCollisionNode(node)
        }
        
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
