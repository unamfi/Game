//
//  GameView.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit

class GameView: SCNView {
    
    var keyboard = NSMutableDictionary()
    
    let relation : CGFloat = 1 / 1000
    
    var α = CGFloat(0)
    var ß = CGFloat(0)
    var s = CGFloat(0)
    
    func updateKeyboardState(character : String?, pressed:Bool) {
        if (character != nil) {
            keyboard.setObject(NSNumber(bool: pressed), forKey: character!)
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        self.updateKeyboardState(theEvent.characters, pressed: true)
    }
    
    override func keyUp(theEvent: NSEvent) {
        self.updateKeyboardState(theEvent.characters, pressed: false)
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        α += (theEvent.deltaX) * relation
        ß += (theEvent.deltaY) * relation
    }

    override func scrollWheel(theEvent: NSEvent) {
        s += (theEvent.deltaY) 
    }
    
    func handleKeyStroke (key : String, stuff : () -> ()) {
        let keyIsPressed = self.keyboard[key] as? NSNumber
        if keyIsPressed != nil && keyIsPressed!.boolValue {
            stuff()
        }
    }
    
}
