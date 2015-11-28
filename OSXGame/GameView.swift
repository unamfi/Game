//
//  GameView.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit

class ContactDelegate : NSObject, SCNPhysicsContactDelegate {
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        
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
        let θ : CGFloat = smiley.rotation.w
        let speed = CGFloat(0.5)
        let pi = CGFloat(π)
        
        self.handleKeyStroke("w") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ) * speed
        }
        self.handleKeyStroke("s") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ + pi) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ + pi) * speed
        }
        self.handleKeyStroke("a") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ + pi / 2) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ + pi / 2) * speed
        }
        self.handleKeyStroke("d") { () -> () in
            self.smiley.position.x = self.smiley.position.x + sin(θ - pi / 2) * speed
            self.smiley.position.z = self.smiley.position.z + cos(θ - pi / 2) * speed
        }
        
        self.handleKeyStroke("e") { () -> () in
            self.camera.camera?.xFov++
            self.camera.camera?.yFov++
        }
        self.handleKeyStroke("q") { () -> () in
            self.camera.camera?.xFov--
            self.camera.camera?.yFov--
        }
    }
    
    func loadNodeFromScene(name:String) -> SCNNode {
        return (self.scene?.rootNode.childNodeWithName(name , recursively: true))!
    }
}
