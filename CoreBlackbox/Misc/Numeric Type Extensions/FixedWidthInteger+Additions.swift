//
//  FixedWidthInteger+Additions.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/14/20.
//  Copyright © 2020 Grady Haynes. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
    
    static func bit(_ index: Int) -> Self {
        assert(index < bitWidth)
        return 1 << index
    }
    
    /// Allow individual bits to be accessed via subscript.
    subscript(bitIndex: Int) -> Bool {
        get {
            assert(bitIndex < bitWidth)
            let mask = Self(1) << bitIndex
            return self & mask == mask
        }
        set {
            assert(bitIndex < bitWidth)
            let mask = Self(1) << bitIndex
            self = newValue ? self | mask : self & ~mask
        }
    }
}

public extension FixedWidthInteger where Self: CVarArg, Self: UnsignedInteger {
    
    var hexString: String {
        String(format: "0x%\(String(format: "%02x", bitWidth / 4))x", self)
    }
    
    var hexStringWithNoLeading0X: String {
        String(format: "%\(String(format: "%02x", bitWidth / 4))x", self)
    }
}
