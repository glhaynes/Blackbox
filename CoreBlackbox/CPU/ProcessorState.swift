//
//  ProcessorState.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 12/1/19.
//  Copyright © 2019 Grady Haynes. All rights reserved.
//

import Foundation

public struct ProcessorState: Equatable {
    
    public enum IRQ: String {
        case none
        case regular
        case nonMaskable  // "NMI"
        case reset
    }

    public var a: UInt8    // Accumulator
    public var x: UInt8    // Index Register X
    public var y: UInt8    // Index Register Y
    public var s: UInt8    // Stack Pointer Register
    public var pc: UInt16  // Program Counter Register
    public var p: ProcessorStatusRegister
    public var pendingIRQ: IRQ
    
    var isHalted: Bool  // TODO: I think this can go away
    var cycleCount: UInt64 // TODO: We could move this to the Computer if we made it in charge of cycle-stepping
    
    public init(a: UInt8, x: UInt8, y: UInt8, s: UInt8, pc: UInt16, p: ProcessorStatusRegister, pendingIRQ: IRQ = .none, isHalted: Bool = false, cycleCount: UInt64 = 0) {
        self.a = a
        self.x = x
        self.y = y
        self.s = s
        self.pc = pc
        self.p = p
        self.pendingIRQ = pendingIRQ
        self.isHalted = isHalted
        self.cycleCount = cycleCount
    }
}

extension ProcessorState: CustomDebugStringConvertible {
    public var debugDescription: String {
        func f8(_ value: UInt8) -> String { String(format: "$%02x", value) }
        func f16(_ value: UInt16) -> String { String(format: "$%04x", value) }
        return "Cycles: \(String(format: "%7d", cycleCount)),  A: \(f8(a))  X: \(f8(x))  Y: \(f8(y))  S: \(f8(s))  PC: \(f16(pc))  P: \(p)  IRQ: \(pendingIRQ.rawValue)"
    }
}
