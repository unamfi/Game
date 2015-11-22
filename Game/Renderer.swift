//
//  File.swift
//  Game
//
//  Created by Julio César Guzman on 11/22/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

func ==(left: SCNVector3, right: SCNVector3) -> Bool {
    return SCNVector3EqualToVector3(left , right)
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func +(left: SCNVector4, right: SCNVector4) -> SCNVector4 {
    return SCNVector4Make(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w)
}

func +(left: NSColor, right: NSColor) -> NSColor {
    return NSColor(red: left.redComponent + right.redComponent , green: left.greenComponent + right.greenComponent, blue: left.blueComponent + right.blueComponent, alpha: 0.0)
}

typealias vectorialFunction = (SCNNode, NSTimeInterval) -> (SCNVector3)
typealias vectorial4Function = (SCNNode, NSTimeInterval) -> (SCNVector4)
typealias colorFunction = (SCNNode, NSTimeInterval) -> (NSColor)

struct UpdatableNode {
   
    var node : SCNNode
    var originalPosition : SCNVector3 = SCNVector3Zero
    var originalRotation : SCNVector4 = SCNVector4Zero
    var originalColor : NSColor
    var movementClosure: vectorialFunction
    var rotationClosure: vectorial4Function
    var colorClosure : colorFunction
    
    init(node: SCNNode , movementClosure: vectorialFunction, rotationClosure : vectorial4Function, colorClosure : colorFunction) {
        self.node = node
        self.originalPosition = node.position
        self.originalRotation = node.rotation
        self.originalColor = (node.light?.color)! as! NSColor
        self.movementClosure = movementClosure
        self.rotationClosure = rotationClosure
        self.colorClosure = colorClosure
    }
    
    func animateOnUpdateCycle (time: NSTimeInterval) {
        self.moveOnUpdateCycle(time)
        self.rotateOnUpdateCycle(time)
        self.moveColorOnUpdateCycle(time)
    }
    
    func moveOnUpdateCycle (time: NSTimeInterval) {
        self.node.position = self.originalPosition + self.movementClosure(self.node, time)
    }
    
    func rotateOnUpdateCycle (time : NSTimeInterval ) {
        self.node.rotation = self.originalRotation + self.rotationClosure(self.node, time)
    }

    func moveColorOnUpdateCycle (time : NSTimeInterval ) {
        self.node.light?.color = self.originalColor + self.colorClosure(self.node, time)
    }
}


class SceneRenderer: NSObject, SCNSceneRendererDelegate {
    
    var scene : SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
    }
}

class PracticaSceneRenderer : SceneRenderer
{
    
    var lastTime : NSTimeInterval = Double(0)

    var updatableNodes : [ UpdatableNode ] = []
    
    override init(scene: SCNScene) {
        super.init(scene: scene)
        self.updatableNodes = [ self.spotlightUpdatableNodeWith(0.0, nodeName: "spot"),
                                self.spotlightUpdatableNodeWith(1.57, nodeName: "spot2"),
                                self.spotlightUpdatableNodeWith(-1.57, nodeName: "spot3"),
                                self.spotlightUpdatableNodeWith(0.0 + 0.785, nodeName: "spot4"),
                                self.spotlightUpdatableNodeWith(1.57 + 0.785, nodeName: "spot5"),
                                self.spotlightUpdatableNodeWith(-1.57 + 0.785, nodeName: "spot6")]
    }
    
    func spotlightUpdatableNodeWith(delay: Double, nodeName: String) -> UpdatableNode {
        
        let barraNodeGeometry = scene.rootNode.childNodeWithName("barra", recursively: true)!.geometry as! SCNBox
        
        let spotNode = scene.rootNode.childNodeWithName(nodeName, recursively: true)!
        
        let spotNodeMovementClosure = {( node:SCNNode, t : NSTimeInterval) -> (SCNVector3) in
            
            let y = sin(CGFloat(t + delay)) * barraNodeGeometry.width / 2
            
            let threshold = barraNodeGeometry.width / 2 - 0.005
            
            if y >= threshold || y <= -threshold {
                node.light?.color = NSColor.randomColor()
            }
            
            return SCNVector3Make( y , 0 , 0)
        }
        
        let spotNodeRotationClosure = {( node:SCNNode, t : NSTimeInterval) -> (SCNVector4) in
            return SCNVector4Make(1.0, 0.0, 0.0, sin(CGFloat(( t + delay ) * 3)) )
        }
        
        let changeColorClosure = {( node:SCNNode, t : NSTimeInterval) -> (NSColor) in
            
            return NSColor(red: sin(CGFloat(t + delay)), green: cos(CGFloat((t + delay) * 2)) , blue: sin(CGFloat((t + delay) * 3)), alpha: 0.0)
        }
        
        return UpdatableNode(node: spotNode,
                  movementClosure: spotNodeMovementClosure,
                  rotationClosure: spotNodeRotationClosure,
                     colorClosure: changeColorClosure)
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        let deltaTime = time - lastTime;
        let t = time + deltaTime
        
        for node in self.updatableNodes {
            node.animateOnUpdateCycle(t)
        }
        
        lastTime = time
    }
    
}