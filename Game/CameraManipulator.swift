//
//  CameraManipulator.swift
//  Game
//
//  Created by Julio César Guzman on 1/16/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import SceneKit

class CameraManipulator {
    
    private var cameraModel : CameraModel!
    private var scene : SCNScene!
    private var pointOfView : SCNNode!
    
    // Nodes to manipulate the camera
    let cameraYHandle = SCNNode()
    let cameraXHandle = SCNNode()
    
    init(pointOfView: SCNNode, scene: SCNScene, cameraModel: CameraModel) {
        self.pointOfView = pointOfView
        self.scene = scene
        self.cameraModel = cameraModel
        initialize()
    }
    
    private func initialize() {
        let ALTITUDE = 1.0
        let DISTANCE = 10.0
        
        // We create 2 nodes to manipulate the camera:
        // The first node "cameraXHandle" is at the center of the world (0, ALTITUDE, 0) and will only rotate on the X axis
        // The second node "cameraYHandle" is a child of the first one and will ony rotate on the Y axis
        // The camera node is a child of the "cameraYHandle" at a specific distance (DISTANCE).
        // So rotating cameraYHandle and cameraXHandle will update the camera position and the camera will always look at the center of the scene.
        
        let pov = pointOfView
        pov.eulerAngles = SCNVector3Zero
        pov.position = SCNVector3(0.0, 0.0, DISTANCE)
        
        cameraXHandle.rotation = SCNVector4(1.0, 0.0, 0.0, -M_PI_4 * 0.125)
        cameraXHandle.addChildNode(pov)
        
        cameraYHandle.position = SCNVector3(0.0, ALTITUDE, 0.0)
        cameraYHandle.rotation = SCNVector4(0.0, 1.0, 0.0, M_PI_2 + M_PI_4 * 3.0)
        cameraYHandle.addChildNode(cameraXHandle)
        
        scene.rootNode.addChildNode(cameraYHandle)
        
        // Animate camera on launch and prevent the user from manipulating the camera until the end of the animation.
        SCNTransaction.animateWithDuration(completionBlock: { self.cameraModel.lockCamera = false }) {
            self.cameraModel.lockCamera = true
            
            // Create 2 additive animations that converge to 0
            // That way at the end of the animation, the camera will be at its default position.
            let cameraYAnimation = CABasicAnimation(keyPath: "rotation.w")
            cameraYAnimation.fromValue = SCNFloat(M_PI) * 2.0 - self.cameraYHandle.rotation.w
            cameraYAnimation.toValue = 0.0
            cameraYAnimation.additive = true
            cameraYAnimation.beginTime = CACurrentMediaTime() + 3.0 // wait a little bit before stating
            cameraYAnimation.fillMode = kCAFillModeBoth
            cameraYAnimation.duration = 5.0
            cameraYAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.cameraYHandle.addAnimation(cameraYAnimation, forKey: nil)
            
            let cameraXAnimation = cameraYAnimation.copy() as! CABasicAnimation
            cameraXAnimation.fromValue = -SCNFloat(M_PI_2) + self.cameraXHandle.rotation.w
            self.cameraXHandle.addAnimation(cameraXAnimation, forKey: nil)
        }
    }
    
    func panCamera(direction : float2) {
        
        if cameraModel.lockCamera {
            return
        }
        
        let F = SCNFloat(0.005)
        
        // Make sure the camera handles are correctly reset (because automatic camera animations may have put the "rotation" in a weird state.
        SCNTransaction.animateWithDuration(0.0) {
            self.cameraYHandle.removeAllActions()
            self.cameraXHandle.removeAllActions()
            
            if self.cameraYHandle.rotation.y < 0 {
                self.cameraYHandle.rotation = SCNVector4(0, 1, 0, -self.cameraYHandle.rotation.w)
            }
            
            if self.cameraXHandle.rotation.x < 0 {
                self.cameraXHandle.rotation = SCNVector4(1, 0, 0, -self.cameraXHandle.rotation.w)
            }
        }
        
        // Update the camera position with some inertia.
        SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)) {
            self.cameraYHandle.rotation = SCNVector4(0, 1, 0, self.cameraYHandle.rotation.y * (self.cameraYHandle.rotation.w - SCNFloat(direction.x) * F))
            self.cameraXHandle.rotation = SCNVector4(1, 0, 0, (max(SCNFloat(-M_PI_2), min(0.13, self.cameraXHandle.rotation.w + SCNFloat(direction.y) * F))))
        }
    }
    
    func animateTheCameraForever() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.cameraYHandle.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y:-1, z: 0, duration: 3)))
            self.cameraXHandle.runAction(SCNAction.rotateToX(CGFloat(-M_PI_4), y: 0, z: 0, duration: 5.0))
        }
    }
    
}