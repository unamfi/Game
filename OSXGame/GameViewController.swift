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
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        self.gameView!.scene = scene
        self.gameView!.allowsCameraControl = true
        self.gameView!.showsStatistics = true
        self.gameView!.backgroundColor = NSColor.blackColor()
        self.gameView!.playing = true
        self.gameView!.loops = true
    }

}
