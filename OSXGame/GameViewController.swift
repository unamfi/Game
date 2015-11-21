//
//  GameViewController.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
    }

}
