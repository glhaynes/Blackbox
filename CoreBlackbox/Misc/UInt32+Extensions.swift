//
//  UInt16+Extensions.swift
//  Swifty502
//
//  Created by Grady Haynes on 12/29/19.
//  Copyright © 2019 Grady Haynes. All rights reserved.
//

import Foundation

extension UInt16 {

    var asBCDValue: UInt16 {
        // TODO: Probably could be optimized significantly
        var result: UInt16 = 0
        for (position, character) in hexString.dropFirst(2).reversed().enumerated() {
            result += UInt16(pow(Double(10), Double(position))) * UInt16(character.hexDigitValue!)
        }
        return result
    }
    
    var bcdAsHexValue: UInt16 {
        var result: UInt16 = 0
        for (position, character) in String(self).reversed().enumerated() {
            result += UInt16(pow(Double(16), Double(position))) * UInt16(character.wholeNumberValue!)
        }
        return result
    }
    
    public var lowByte: UInt8 {
        get {
            UInt8(self & 0x00ff)
        }
        set {
            self = UInt16(highByte: self.highByte, lowByte: newValue)
        }
    }

    public var highByte: UInt8 {
        get {
            UInt8(self >> 8)
        }
        set {
            self = UInt16(highByte: newValue, lowByte: self.lowByte)
        }
    }
    
    init(highByte: UInt8) {
        self = UInt16(highByte) << 8
    }
    
    init(lowByte: UInt8) {
        self = UInt16(lowByte)
    }
        
    init(highByte: UInt8, lowByte: UInt8) {
        self = (UInt16(highByte) << 8) | UInt16(lowByte)
    }
}
