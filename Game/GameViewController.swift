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

// Collision bit masks
let BitmaskCollision        = 1 << 2
let BitmaskCollectable      = 1 << 3
let BitmaskEnemy            = 1 << 4
let BitmaskSuperCollectable = 1 << 5
let BitmaskWater            = 1 << 6

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
    
    // Game states
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
    
    private var sceneRendererDelegate : SceneRendererDelegate!
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new scene.
        let scene = SCNScene(named: "game.scnassets/level.scn")!
        
        // Set the scene to the view and loop for the animation of the bamboos.
        self.gameView.scene = scene
        self.gameView.playing = true
        self.gameView.loops = true
        
        // Set the game component
        self.game = Game(gameView: gameView)
        
        // Various setup
        game.setupCamera()
        game.setupSounds()
        
        // Configure particle systems
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
        scene.physicsWorld.contactDelegate = self
        self.sceneRendererDelegate = SceneRendererDelegate(game: game, controllerDirection: controllerDirection)
        gameView.delegate = sceneRendererDelegate
        
       
        setupGameControllers()
    }
    
    // MARK: Managing the Camera
    
    func panCamera(var direction: float2) {
        if game.lockCamera {
            return
        }
        
        #if os(iOS) || os(tvOS)
            direction *= float2(1.0, -1.0)
        #endif
        
        let F = SCNFloat(0.005)
        
        // Make sure the camera handles are correctly reset (because automatic camera animations may have put the "rotation" in a weird state.
        SCNTransaction.animateWithDuration(0.0) {
            self.game.cameraYHandle.removeAllActions()
            self.game.cameraXHandle.removeAllActions()
            
            if self.game.cameraYHandle.rotation.y < 0 {
                self.game.cameraYHandle.rotation = SCNVector4(0, 1, 0, -self.game.cameraYHandle.rotation.w)
            }
            
            if self.game.cameraXHandle.rotation.x < 0 {
                self.game.cameraXHandle.rotation = SCNVector4(1, 0, 0, -self.game.cameraXHandle.rotation.w)
            }
        }
        
        // Update the camera position with some inertia.
        SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)) {
            self.game.cameraYHandle.rotation = SCNVector4(0, 1, 0, self.game.cameraYHandle.rotation.y * (self.game.cameraYHandle.rotation.w - SCNFloat(direction.x) * F))
            self.game.cameraXHandle.rotation = SCNVector4(1, 0, 0, (max(SCNFloat(-M_PI_2), min(0.13, self.game.cameraXHandle.rotation.w + SCNFloat(direction.y) * F))))
        }
    }
    
    // MARK: SCNPhysicsContactDelegate Conformance
    
    // To receive contact messages, you set the contactDelegate property of an SCNPhysicsWorld object.
    // SceneKit calls your delegate methods when a contact begins, when information about the contact changes, and when the contact ends.
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        contact.match(category: BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
        contact.match(category: BitmaskCollectable) { (matching, _) in
            self.collectPearl(matching)
        }
        contact.match(category: BitmaskSuperCollectable) { (matching, _) in
            self.collectFlower(matching)
        }
        contact.match(category: BitmaskEnemy) { (_, _) in
            self.game.character.catchFire()
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        contact.match(category: BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
    }
    
    private func characterNode(characterNode: SCNNode, hitWall wall: SCNNode, withContact contact: SCNPhysicsContact) {
        if characterNode.parentNode != game.character.node {
            return
        }
        
        if self.game.character.maxPenetrationDistance > contact.penetrationDistance {
            return
        }
        
        self.game.character.maxPenetrationDistance = contact.penetrationDistance
        
        var characterPosition = float3(game.character.node.position)
        var positionOffset = float3(contact.contactNormal) * Float(contact.penetrationDistance)
        positionOffset.y = 0
        characterPosition += positionOffset
        
        self.game.character.replacementPosition = SCNVector3(characterPosition)
    }
    
    // MARK: Collecting Items
    
    private func removeNode(node: SCNNode, soundToPlay sound: SCNAudioSource) {
        if let parentNode = node.parentNode {
            let soundEmitter = SCNNode()
            soundEmitter.position = node.position
            parentNode.addChildNode(soundEmitter)
            
            soundEmitter.runAction(SCNAction.sequence([
                SCNAction.playAudioSource(sound, waitForCompletion: true),
                SCNAction.removeFromParentNode()]))
            
            node.removeFromParentNode()
        }
    }
    
    private var collectedPearlsCount = 0 {
        didSet {
            gameView.collectedPearlsCount = collectedPearlsCount
        }
    }
    
    private func collectPearl(pearlNode: SCNNode) {
        if pearlNode.parentNode != nil {
            removeNode(pearlNode, soundToPlay:self.game.collectPearlSound)
            collectedPearlsCount++
        }
    }
    
    private var collectedFlowersCount = 0 {
        didSet {
            gameView.collectedFlowersCount = collectedFlowersCount
            if (collectedFlowersCount == 3) {
                showEndScreen()
            }
        }
    }
    
    private func collectFlower(flowerNode: SCNNode) {
        if flowerNode.parentNode != nil {
            // Emit particles.
            var particleSystemPosition = flowerNode.worldTransform
            particleSystemPosition.m42 += 0.1
            gameView.scene!.addParticleSystem(game.collectFlowerParticleSystem, withTransform: particleSystemPosition)
            
            // Remove the flower from the scene.
            removeNode(flowerNode, soundToPlay:self.game.collectFlowerSound)
            collectedFlowersCount++
        }
    }
    
    // MARK: Congratulating the Player
    
    private func showEndScreen() {
        game.isComplete = true
        
        // Add confettis
        let particleSystemPosition = SCNMatrix4MakeTranslation(0.0, 8.0, 0.0)
        gameView.scene!.addParticleSystem(game.confettiParticleSystem, withTransform: particleSystemPosition)
        
        // Stop the music.
        gameView.scene!.rootNode.removeAllAudioPlayers()
        
        // Play the congrat sound.
        gameView.scene!.rootNode.addAudioPlayer(SCNAudioPlayer(source: self.game.victoryMusic))
        
        // Animate the camera forever
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.game.cameraYHandle.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y:-1, z: 0, duration: 3)))
            self.game.cameraXHandle.runAction(SCNAction.rotateToX(CGFloat(-M_PI_4), y: 0, z: 0, duration: 5.0))
        }
        
        gameView.showEndScreen();
    }
    
}
