//
//  NESRenderPalette.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/17/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum NESRenderPalette {
    
    // TODO: Add a reference to where these values came from
    
    public static subscript(index: NESColorIndex) -> RGBValue {
        values[Int(index)]
    }

    private static let values: [RGBValue] = [
        // 0x00
        .init(84, 84, 84),
        .init(0, 30, 116),
        .init(8, 16, 144),
        .init(48, 0, 136),
        .init(68, 0, 100),
        .init(92, 0, 48),
        .init(84, 4, 0),
        .init(60, 24, 0),
        .init(32, 42, 0),
        .init(8, 58, 0),
        .init(0, 64, 0),
        .init(0, 60, 0),
        .init(0, 50, 60),
        .init(0, 0, 0),
        .init(0, 0, 0),
        .init(0, 0, 0),
        
        // 0x10
        .init(152, 150, 152),
        .init(8, 76, 196),
        .init(48, 50, 236),
        .init(92, 30, 228),
        .init(136, 20, 176),
        .init(160, 20, 100),
        .init(152, 34, 32),
        .init(120, 60, 0),
        .init(84, 90, 0),
        .init(40, 114, 0),
        .init(8, 124, 0),
        .init(0, 118, 40),
        .init(0, 102, 120),
        .init(0, 0, 0),
        .init(0, 0, 0),
        .init(0, 0, 0),
        
        // 0x20
        .init(236, 238, 236),
        .init(76, 154, 236),
        .init(120, 124, 236),
        .init(176, 98, 236),
        .init(228, 84, 236),
        .init(236, 88, 180),
        .init(236, 106, 100),
        .init(212, 136, 32),
        .init(160, 170, 0),
        .init(116, 196, 0),
        .init(76, 208, 32),
        .init(56, 204, 108),
        .init(56, 180, 204),
        .init(60, 60, 60),
        .init(0, 0, 0),
        .init(0, 0, 0),
        
        // 0x30
        .init(236, 238, 236),
        .init(168, 204, 236),
        .init(188, 188, 236),
        .init(212, 178, 236),
        .init(236, 174, 236),
        .init(236, 174, 212),
        .init(236, 180, 176),
        .init(228, 196, 144),
        .init(204, 210, 120),
        .init(180, 222, 120),
        .init(168, 226, 144),
        .init(152, 226, 180),
        .init(160, 214, 228),
        .init(160, 162, 160),
        .init(0, 0, 0),
        .init(0, 0, 0)
    ]
}

private extension RGBValue {
    init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        // This is just to make the syntax above lighter.
        // TODO: A Result Builder might be an interesting way to improve this?
        self = RGBValue(red: red, green: green, blue: blue)
    }
}
