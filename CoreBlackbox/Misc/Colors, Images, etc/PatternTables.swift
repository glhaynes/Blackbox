//
//  PatternTables.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/14/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public struct PatternTables {
    public var one: Sprite
    public var two: Sprite
    
    public init() {
        self.one = .init(width: 0, height: 0)
        self.two = .init(width: 0, height: 0)
    }
    
    public init(one: Sprite, two: Sprite) {
        self.one = one
        self.two = two
    }
}
