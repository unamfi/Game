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
    
    // The character
    private let character = Character()
    
    // Game states
    private var game : Game!
    private var lockCamera = false
    
    // Particles
    private var confettiParticleSystem: SCNParticleSystem!
    private var collectFlowerParticleSystem: SCNParticleSystem!
    
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
        self.game = Game(scene: scene)
        
        // Various setup
        setupCamera()
        setupSounds()
        
        // Configure particle systems
        collectFlowerParticleSystem = SCNParticleSystem(named: "collect.scnp", inDirectory: nil)
        collectFlowerParticleSystem.loops = false
        confettiParticleSystem = SCNParticleSystem(named: "confetti.scnp", inDirectory: nil)
        
        // Add the character to the scene.
        scene.rootNode.addChildNode(character.node)
        
        let startPosition = scene.rootNode.childNodeWithName("startingPoint", recursively: true)!
        character.node.transform = startPosition.transform
        
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
            setupCollisionNode(node)
        }
        
        // Setup delegates
        scene.physicsWorld.contactDelegate = self
        self.sceneRendererDelegate = SceneRendererDelegate( character: character,
                                                                 game: game,
                                                             gameView: gameView,
                                                  controllerDirection: controllerDirection)
        
        gameView.delegate = sceneRendererDelegate
        
       
        setupGameControllers()
    }
    
    // MARK: Managing the Camera
    
    func panCamera(var direction: float2) {
        if lockCamera {
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
            self.character.catchFire()
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        contact.match(category: BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
    }
    
    private func characterNode(characterNode: SCNNode, hitWall wall: SCNNode, withContact contact: SCNPhysicsContact) {
        if characterNode.parentNode != character.node {
            return
        }
        
        if self.character.maxPenetrationDistance > contact.penetrationDistance {
            return
        }
        
        self.character.maxPenetrationDistance = contact.penetrationDistance
        
        var characterPosition = float3(character.node.position)
        var positionOffset = float3(contact.contactNormal) * Float(contact.penetrationDistance)
        positionOffset.y = 0
        characterPosition += positionOffset
        
        self.character.replacementPosition = SCNVector3(characterPosition)
    }
    
    // MARK: Scene Setup
    
    private func setupCamera() {
        let ALTITUDE = 1.0
        let DISTANCE = 10.0
        
        // We create 2 nodes to manipulate the camera:
        // The first node "cameraXHandle" is at the center of the world (0, ALTITUDE, 0) and will only rotate on the X axis
        // The second node "cameraYHandle" is a child of the first one and will ony rotate on the Y axis
        // The camera node is a child of the "cameraYHandle" at a specific distance (DISTANCE).
        // So rotating cameraYHandle and cameraXHandle will update the camera position and the camera will always look at the center of the scene.
        
        let pov = self.gameView.pointOfView!
        pov.eulerAngles = SCNVector3Zero
        pov.position = SCNVector3(0.0, 0.0, DISTANCE)
        
        game.cameraXHandle.rotation = SCNVector4(1.0, 0.0, 0.0, -M_PI_4 * 0.125)
        game.cameraXHandle.addChildNode(pov)
        
        game.cameraYHandle.position = SCNVector3(0.0, ALTITUDE, 0.0)
        game.cameraYHandle.rotation = SCNVector4(0.0, 1.0, 0.0, M_PI_2 + M_PI_4 * 3.0)
        game.cameraYHandle.addChildNode(game.cameraXHandle)
        
        gameView.scene?.rootNode.addChildNode(game.cameraYHandle)
        
        // Animate camera on launch and prevent the user from manipulating the camera until the end of the animation.
        SCNTransaction.animateWithDuration(completionBlock: { self.lockCamera = false }) {
            self.lockCamera = true
            
            // Create 2 additive animations that converge to 0
            // That way at the end of the animation, the camera will be at its default position.
            let cameraYAnimation = CABasicAnimation(keyPath: "rotation.w")
            cameraYAnimation.fromValue = SCNFloat(M_PI) * 2.0 - self.game.cameraYHandle.rotation.w
            cameraYAnimation.toValue = 0.0
            cameraYAnimation.additive = true
            cameraYAnimation.beginTime = CACurrentMediaTime() + 3.0 // wait a little bit before stating
            cameraYAnimation.fillMode = kCAFillModeBoth
            cameraYAnimation.duration = 5.0
            cameraYAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.game.cameraYHandle.addAnimation(cameraYAnimation, forKey: nil)
            
            let cameraXAnimation = cameraYAnimation.copy() as! CABasicAnimation
            cameraXAnimation.fromValue = -SCNFloat(M_PI_2) + self.game.cameraXHandle.rotation.w
            self.game.cameraXHandle.addAnimation(cameraXAnimation, forKey: nil)
        }
    }
    
    private func setupCollisionNode(node: SCNNode) {
        if let geometry = node.geometry {
            // Collision meshes must use a concave shape for intersection correctness.
            node.physicsBody = SCNPhysicsBody.staticBody()
            node.physicsBody!.categoryBitMask = BitmaskCollision
            node.physicsBody!.physicsShape = SCNPhysicsShape(node: node, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron])
            
            // Get grass area to play the right sound steps
            if geometry.firstMaterial!.name == "grass-area" {
                if self.game.grassArea != nil {
                    geometry.firstMaterial = self.game.grassArea
                } else {
                    self.game.grassArea = geometry.firstMaterial
                }
            }
            
            // Get the water area
            if geometry.firstMaterial!.name == "water" {
                self.game.waterArea = geometry.firstMaterial
            }
            
            // Temporary workaround because concave shape created from geometry instead of node fails
            let childNode = SCNNode()
            node.addChildNode(childNode)
            childNode.hidden = true
            childNode.geometry = node.geometry
            node.geometry = nil
            node.hidden = false
            
            if node.name == "water" {
                node.physicsBody!.categoryBitMask = BitmaskWater
            }
        }
        
        for childNode in node.childNodes {
            if childNode.hidden == false {
                setupCollisionNode(childNode)
            }
        }
    }
    
    private func setupSounds() {
        // Get an arbitrary node to attach the sounds to.
        let node = gameView.scene!.rootNode
        
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: "music.m4a", volume: 0.25, positional: false, loops: true, shouldStream: true)))
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: "wind.m4a", volume: 0.3, positional: false, loops: true, shouldStream: true)))
        game.flameThrowerSound = SCNAudioPlayer(source: SCNAudioSource(name: "flamethrower.mp3", volume: 0, positional: false, loops: true))
        node.addAudioPlayer(self.game.flameThrowerSound)
        
        game.collectPearlSound = SCNAudioSource(name: "collect1.mp3", volume: 0.5)
        game.collectFlowerSound = SCNAudioSource(name: "collect2.mp3")
        game.victoryMusic = SCNAudioSource(name: "Music_victory.mp3", volume: 0.5, shouldLoad: false)
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
            gameView.scene!.addParticleSystem(collectFlowerParticleSystem, withTransform: particleSystemPosition)
            
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
        gameView.scene!.addParticleSystem(confettiParticleSystem, withTransform: particleSystemPosition)
        
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
