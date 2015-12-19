//
//  GameViewController.swift
//  tvOSGame
//
//  Created by Julio César Guzman on 12/18/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    @IBOutlet var scnView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.blackColor()
        scnView.playing = true
    }
}
