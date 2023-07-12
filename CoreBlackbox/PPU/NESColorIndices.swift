//
//  NESColorIndices.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct NESColorIndices {
    static let systemBackground = Self(color: 0, palette: 0)
        
    // TODO: Colors should be in range (0...3) and palettes should be in range (0...7); would be nice to assert that
    var color: UInt8
    var palette: UInt8
    
    var isSystemBackground: Bool { color == 0 }
}
