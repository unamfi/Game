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

protocol Controller {
    var performOnKeyboardStroke : (() -> ())? { get set }
}

class TextFieldDelegate : NSObject, UITextFieldDelegate, Controller
{
    var performOnKeyboardStroke : (() -> ())?
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.performOnKeyboardStroke!()
        return false;
    }
}

class GameViewController: UIViewController {

    @IBOutlet var scnView: SCNView!
    
    @IBOutlet var textField: UITextField!
    
    var smiley : SCNNode?
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        
        scnView.backgroundColor = UIColor.blackColor()
        
        //Input
        textFieldDelegate.performOnKeyboardStroke = { () -> () in
            self.smiley?.physicsBody?.applyForce(SCNVector3Make(0.0, 10, 0.0), impulse: true)
        }
    
        self.textField.delegate = textFieldDelegate
        
        //Player
        self.smiley = self.scnView.scene?.rootNode.childNodeWithName("smiley", recursively: false)
        
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
    
  

}
