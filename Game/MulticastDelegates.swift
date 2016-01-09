//
//  MulticastDelegates.swift
//  Game
//
//  Created by Julio César Guzman on 1/9/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation

class DelegateMulticast <T> {
    
    private var delegates = [T]()
    
    func addDelegate(delegate: T) {
        delegates.append(delegate)
    }
    
    func invokeDelegates(invocation: (T) -> ()) {
        for delegate in delegates {
            invocation(delegate)
        }
    }
}