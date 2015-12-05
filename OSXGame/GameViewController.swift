//
//  GameViewController.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit
import QuartzCore

let commonBitMaskToEnableContactDelegate = 8

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    var renderer : SceneRenderer?
    var contactDelegate : DecalContactDelegate?
    
    override func awakeFromNib(){
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        self.gameView!.scene = scene
        self.renderer = PracticaSceneRenderer(scene: scene, view: self.gameView)
        gameView.delegate = self.renderer
        self.gameView!.allowsCameraControl = false
        self.gameView!.showsStatistics = true
        self.gameView!.backgroundColor = NSColor.blackColor()
        self.gameView!.playing = true
        self.gameView!.loops = true
        self.gameView!.window?.acceptsMouseMovedEvents = true
        
        let decalNode = self.gameView.scene?.rootNode.childNodeWithName("plane", recursively: true)!
        self.contactDelegate = DecalContactDelegate(decalNode: decalNode!, sceneRootNode: self.gameView.scene!.rootNode)
        self.gameView.scene?.physicsWorld.contactDelegate = self.contactDelegate
        
        self.setupBitMasksForContact()
    }

    func setupBitMasksForContact() {
        let bullet = self.gameView.scene?.rootNode.childNodeWithName("bullet", recursively: true)!
        bullet?.physicsBody?.categoryBitMask = commonBitMaskToEnableContactDelegate
        bullet!.physicsBody?.contactTestBitMask = commonBitMaskToEnableContactDelegate
        let floor = self.gameView.scene?.rootNode.childNodeWithName("floor", recursively: true)!
        floor!.physicsBody?.categoryBitMask = commonBitMaskToEnableContactDelegate
        floor!.physicsBody?.contactTestBitMask = commonBitMaskToEnableContactDelegate
    }

}
