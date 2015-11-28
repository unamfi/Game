//
//  GameViewController.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit
import QuartzCore

extension NSColor {
    static func randomColor () -> (NSColor) {
        let red = CGFloat(random(256))/256 as CGFloat
        let green = CGFloat(random(256))/256 as CGFloat
        let blue = CGFloat(random(256))/256 as CGFloat
        return NSColor(red: red , green: green , blue: blue , alpha: 1.0)
    }
}

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    var renderer : SceneRenderer?
    var contactDelegate : ContactDelegate?
    
    override func awakeFromNib(){
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
       
        // set the scene to the view
        self.gameView!.scene = scene
        
        //Set renderer
        self.renderer = PracticaSceneRenderer(scene: scene, view: self.gameView)
        gameView.delegate = self.renderer
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
        
        
        self.gameView!.playing = true
        self.gameView!.loops = true
        self.gameView!.window?.acceptsMouseMovedEvents = true
        
        self.contactDelegate = ContactDelegate()
        
        self.gameView.scene?.physicsWorld.contactDelegate = self.contactDelegate
        
        let bullet = self.gameView.scene?.rootNode.childNodeWithName("bullet", recursively: true)!
        bullet?.physicsBody?.categoryBitMask = 8
        bullet!.physicsBody?.contactTestBitMask = 8
        let sphere = self.gameView.scene?.rootNode.childNodeWithName("sphere", recursively: true)!
        bullet?.physicsBody?.categoryBitMask = 8
        sphere!.physicsBody?.contactTestBitMask = 8
    }

}
