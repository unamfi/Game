//
//  Extensions.swift
//  Game
//
//  Created by Julio César Guzman on 12/5/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import Cocoa

extension NSColor {
    static func randomColor () -> (NSColor) {
        let red = CGFloat(random(256))/256 as CGFloat
        let green = CGFloat(random(256))/256 as CGFloat
        let blue = CGFloat(random(256))/256 as CGFloat
        return NSColor(red: red , green: green , blue: blue , alpha: 1.0)
    }
}
