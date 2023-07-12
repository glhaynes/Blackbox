//
//  OAMEntry.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct OAMEntry {
    
    subscript(byteIndex: Int) -> UInt8 {
        get {
            switch byteIndex {
            case 0: return y
            case 1: return tileIndex
            case 2: return attributes
            case 3: return x
            default: fatalError()
            }
        }
        set {
            switch byteIndex {
            case 0: y = newValue
            case 1: tileIndex = newValue
            case 2: attributes = newValue
            case 3: x = newValue
            default: fatalError()
            }

        }
    }

    var isFlippedHorizontally: Bool {
        attributes & 0x40 != 0
    }
    
    var isFlippedVertically: Bool {
        attributes & 0x80 != 0
    }
    
    var isForegroundPrioritized: Bool {
        attributes & 0x20 == 0
    }
    
    var foregroundPaletteIndex: UInt8 {
        (attributes & 0x03) + 0x04
    }
    
    var tileIndex: UInt8 = 0
    var x: UInt8 = 0
    var y: UInt8 = 0
    var attributes: UInt8 = 0
}
