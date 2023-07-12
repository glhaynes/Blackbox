//
//  Sprite.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/13/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public struct Sprite {
    
    public private(set) var rgbValues: [[RGBValue]]
    
    public var width: Int {
        rgbValues.first!.count
    }
    
    public var height: Int {
        rgbValues.count
    }
    
    public init(width: Int, height: Int) {
        let black = RGBValue(red: 0, green: 0, blue: 0)
        let row: [RGBValue] = .init(repeatElement(black, count: width))
        rgbValues = .init(repeatElement(row, count: height))
    }
    
    public mutating func setPixel(x: Int, y: Int, value: RGBValue) {
        rgbValues[y][x] = value
    }
}
