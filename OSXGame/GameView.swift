//
//  GameView.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit

class ContactDelegate : NSObject, SCNPhysicsContactDelegate {
    
    var scene : SCNScene?
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        let nodesInCollission = [nodeA, nodeB]
        
        if nodeA.physicsBody?.categoryBitMask == commonBitMaskToEnableContactDelegate &&
            nodeB.physicsBody?.categoryBitMask == commonBitMaskToEnableContactDelegate {
                for node in nodesInCollission {
                    if magnitudeOf(node.physicsBody!.velocity) == 0 {
                        self.addDamageToNode(node, contact: contact)
                    }
                }
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        
    }
    
    func addDamageToNode(node : SCNNode, contact: SCNPhysicsContact) {
        //TODO: Add decal here
    }
}

class InputView: SCNView {
    
    var keyboard = NSMutableDictionary()
    let mouseMovementRelation : CGFloat = 1 / 1000
    var mouseMoveX = CGFloat(0)
    var mouseMoveY = CGFloat(0)
    
    override func keyDown(theEvent: NSEvent) {
        super.keyDown(theEvent)
        self.updateKeyboardState(theEvent.characters, pressed: true)
    }
    
    override func keyUp(theEvent: NSEvent) {
        super.keyUp(theEvent)
        self.updateKeyboardState(theEvent.characters, pressed: false)
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        super.mouseMoved(theEvent)
    
        mouseMoveX += (theEvent.deltaX) * mouseMovementRelation
        mouseMoveY += (theEvent.deltaY) * mouseMovementRelation
    }
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
    }
    
    func updateKeyboardState(character : String?, pressed:Bool) {
        if (character != nil) {
            keyboard.setObject(NSNumber(bool: pressed), forKey: character!)
        }
    }
    
    func handleKeyStroke (key : String, handler : () -> ()) {
        let keyIsPressedValue = self.keyboard[key] as? NSNumber
        if keyIsPressedValue != nil && keyIsPressedValue!.boolValue {
            handler()
        }
    }
    
}

class GameView: InputView {
    
    var smiley : SCNNode {
        get {
            return self.loadNodeFromScene("smiley")
        }
    }
    
    var camera : SCNNode {
        get {
            return self.loadNodeFromScene("camera")
        }
    }
    
    var weapon : SCNNode {
        get {
            return self.loadNodeFromScene("weapon")
        }
    }
    
    var bullet : SCNNode {
        get {
            return self.loadNodeFromScene("bullet")
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        super.mouseMoved(theEvent)
        self.performRotation()
    }
    
    override func keyDown(theEvent: NSEvent) {
        super.keyDown(theEvent)
        self.handleKeyStroke("p") { () -> () in
            self.shoot()
        }
    }
    
    func shoot() {
        let weapon = self.weapon
        let bullet = self.bullet
      
        let force : CGFloat = 500
        
        let pointA = weapon.convertPosition(SCNVector3Make(0.0, 0.0, 1.0), toNode: self.scene!.rootNode)
        let pointB = weapon.convertPosition(SCNVector3Zero, toNode: self.scene!.rootNode)
        let directionalVector = pointA - pointB
        let forceVector = SCNVector3Make(directionalVector.x * force, directionalVector.y * force, directionalVector.z * force)
        
        bullet.physicsBody?.velocity = SCNVector3Zero
        bullet.physicsBody?.angularVelocity = SCNVector4Zero;
        bullet.physicsBody?.affectedByGravity = false
        bullet.position = pointB
        bullet.physicsBody?.applyForce(forceVector, impulse: true)
        
        self.scene?.rootNode.addChildNode(bullet)
    }
    
    func performRotation () {
        let α = -self.mouseMoveX
        let ß = -self.mouseMoveY
        
        smiley.rotation = SCNVector4Make(0.0, 1.0, 0.0, α)
        camera.rotation = SCNVector4Make(1.0, 0.0, 0.0, ß)
    }
    
    func performOnUpdate () {
        self.handleKeyStrokes()
    }
    
    func handleKeyStrokes () {
        let speed = CGFloat(0.5)
        let pi = CGFloat(π)
        let smiley = self.smiley
        let camera = self.camera
        let θ : CGFloat = smiley.rotation.w
        
        self.handleKeyStroke("w") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ) * speed
            smiley.position.z = smiley.position.z + cos(θ) * speed
        }
        self.handleKeyStroke("s") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ + pi) * speed
            smiley.position.z = smiley.position.z + cos(θ + pi) * speed
        }
        self.handleKeyStroke("a") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ + pi / 2) * speed
            smiley.position.z = smiley.position.z + cos(θ + pi / 2) * speed
        }
        self.handleKeyStroke("d") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ - pi / 2) * speed
            smiley.position.z = smiley.position.z + cos(θ - pi / 2) * speed
        }
        
        self.handleKeyStroke("e") { () -> () in
            camera.camera?.xFov++
            camera.camera?.yFov++
        }
        self.handleKeyStroke("q") { () -> () in
            camera.camera?.xFov--
            camera.camera?.yFov--
        }
    }
    
    func loadNodeFromScene(name:String) -> SCNNode {
        return (self.scene?.rootNode.childNodeWithName(name , recursively: true))!
    }
}
