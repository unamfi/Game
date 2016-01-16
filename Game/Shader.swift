//
//  Shader.swift
//  Game
//
//  Created by Julio César Guzman on 1/14/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation

class Shader {
    
    private let fileType = "shader"
    private let shaderDirectory = "Shaders"
    private(set) var program : String
    
    init(name: String) {
        let pathOfGeometryShader = NSBundle.mainBundle().pathForResource(name, ofType: fileType, inDirectory: shaderDirectory)!
        program = try! String(contentsOfFile: pathOfGeometryShader, encoding: NSUTF8StringEncoding)
    }
}
