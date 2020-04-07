//
//  Box.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 4/6/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import Foundation

/**
 * A simple property wrapper so that objects can observe/bind to properties of another object using closures,
 * Great way to bind view controllers to view model properties, just watch out for retain cycles:
 */
class Box<T>
{
    var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            self.listener?(value)
        }
    }
    
    init(_ value: T)
    {
        self.value = value
    }
    
    // Most likely you need to use [unowned self] here or capture the refs that you use inside:
    func bind(listener: ((T) -> Void)?)
    {
        // set & fire
        self.listener = listener
        self.listener?(value)
    }
}

