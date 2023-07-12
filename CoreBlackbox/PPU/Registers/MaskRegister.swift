//
//  MaskRegister.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct MaskRegister: BitFieldAccessible {
    private static let grayscale: (UInt8, UInt8) = bitmaskTuple(startBit: 0)
    private static let renderBackgroundLeft: (UInt8, UInt8) = bitmaskTuple(startBit: 1)
    private static let renderSpritesLeft: (UInt8, UInt8) = bitmaskTuple(startBit: 2)
    private static let renderBackground: (UInt8, UInt8) = bitmaskTuple(startBit: 3)
    private static let renderSprites: (UInt8, UInt8) = bitmaskTuple(startBit: 4)
    private static let enhanceRed: (UInt8, UInt8) = bitmaskTuple(startBit: 5)
    private static let enhanceGreen: (UInt8, UInt8) = bitmaskTuple(startBit: 6)
    private static let enhanceBlue: (UInt8, UInt8) = bitmaskTuple(startBit: 7)
    
    var isGrayscale: Bool {
        self[Self.grayscale] != 0
    }
    
    var isRenderingSprites: Bool {
        self[Self.renderSprites] != 0
    }

    var isRenderingSpritesLeft: Bool {
        self[Self.renderSpritesLeft] != 0
    }

    var isRenderingBackground: Bool {
        self[Self.renderBackground] != 0
    }
    
    var isRenderingBackgroundLeft: Bool {
        self[Self.renderBackgroundLeft] != 0
    }
    
    var value: UInt8 = 0
}
