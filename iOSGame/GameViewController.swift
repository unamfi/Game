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

extension UIColor {
    static func randomColor () -> (UIColor) {
        let red = CGFloat(arc4random_uniform(UInt32(256)))/256.0 as CGFloat
        let green = CGFloat(arc4random_uniform(UInt32(256)))/256.0 as CGFloat
        let blue = CGFloat(arc4random_uniform(UInt32(256)))/256.0 as CGFloat
        return UIColor(red: red , green: green , blue: blue , alpha: 1.0)
    }
}

protocol Controller {
    var performOnKeyboardStroke : ((String) -> ())? { get set }
}

class TextFieldDelegate : NSObject, UITextFieldDelegate, Controller
{
    var performOnKeyboardStroke : ((String) -> ())?
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.performOnKeyboardStroke!(string)
        return false;
    }
}

class GameViewController: UIViewController {

    @IBOutlet var scnView: SCNView!
    
    var renderer : SceneRenderer?
    
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
        
        //continuously render
        scnView.playing = true
        
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
