//
//  GameViewController.swift
//  Game
//
//  Created by Julio César Guzman on 11/19/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

class GameViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet var scnView: SCNView!
    
    @IBOutlet var textField: UITextField!
    
    var smiley : SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/emptyScene.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 3, z: 0)
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        //Input
        self.textField.delegate = self
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        if string == " " {
            let scene2 = SCNScene(named: "art.scnassets/scene2.scn")!
            let scene3 = SCNScene(named: "art.scnassets/scene3.scn")!
            let scene4 = SCNScene(named: "art.scnassets/scene4.scn")!
            self.addChildNodesFromTwoRandomScenesFromArrayToCurrentScene([ scene2, scene3, scene4 ])
        }

        return false;
    }
    
    func addChildNodesFromTwoRandomScenesFromArrayToCurrentScene(scenes:[SCNScene])
    {
        for childNode in (self.scnView.scene?.rootNode.childNodes)! {
            childNode.removeFromParentNode()
        }
        
        let firstScene = scenes.randomItem()
        let secondScene = scenes.randomItem()
        for node in firstScene.rootNode.childNodes {
            self.scnView.scene!.rootNode.addChildNode(node)
        }
        for node in secondScene.rootNode.childNodes {
            self.scnView.scene!.rootNode.addChildNode(node)
        }
    }

}
