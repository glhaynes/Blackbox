//
//  BitFieldAccessible.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/10/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

protocol BitFieldAccessible {
    associatedtype U: UnsignedInteger
    var value: U { get set }
}

extension BitFieldAccessible {
    
    /// Returns a tuple consisting of the appropriate bitmask and the index of the least significant bit. This way, bitfield values can easily be masked and shifted right to obtain the value of just that bitfield.
    static func bitmaskTuple<U: UnsignedInteger>(startBit: Int, size: Int = 1) -> (mask: U, startBit: U) {
        ((0..<size).reduce(U.zero) { partial, i in
            (partial << 1) | 1
        } << startBit, U(startBit))
    }

    subscript(mask: (U, U)) -> U {
        get {
            (value & mask.0) >> mask.1
        }
        set {
            let shifted = newValue << mask.1
            value = (value & ~mask.0) | (shifted & mask.0)
        }
    }        
}
