//
//  SystemPalette.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/15/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

// We use tuples for these since they're fixed-length arrays. I'm not sure it's the best choice, but I don't really love using dynamic arrays for these fixed-size structures, either, and these are probably slightly more performant so I'm keeping it this way for now
public typealias NESPalette = (NESColorIndex, NESColorIndex, NESColorIndex)
public typealias NESPalettes = (NESPalette, NESPalette, NESPalette, NESPalette, NESPalette, NESPalette, NESPalette, NESPalette)

public struct SystemPalette {
    public var background: NESColorIndex
    public var palettes: NESPalettes
    
    public init(background: NESColorIndex, palettes: NESPalettes) {
        self.background = background
        self.palettes = palettes
    }
}
