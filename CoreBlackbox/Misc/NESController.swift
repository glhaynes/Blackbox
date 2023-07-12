//
//  NESController.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public final class NESController {
    
    public enum Button: UInt8, Hashable {
        case a = 0x80,
             b = 0x40,
             select = 0x20,
             start = 0x10,
             up = 0x8,
             down = 0x4,
             left = 0x2,
             right = 0x1
    }
    
    public var pressedButtons: Set<Button> = []
    private var shiftRegister: UInt8 = 0
    
    public init() { }

    func latch() {
        shiftRegister = initialShiftRegisterValue()
    }

    func read() -> UInt8 {
        defer { shiftRegister <<= 1 }
        return shiftRegister[7] ? 1 : 0
    }
    
    private func initialShiftRegisterValue() -> UInt8 {
        pressedButtons.reduce(UInt8(0)) { result, button in
            result | button.rawValue
        }
    }
}
