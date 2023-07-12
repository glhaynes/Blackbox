//
//  ProcessorState+ProcessorStatusRegister.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 11/19/21.
//  Copyright © 2021 Grady Haynes. All rights reserved.
//

import Foundation

extension ProcessorState {
    
    public struct ProcessorStatusRegister: ExpressibleByIntegerLiteral, Equatable {
    
        public enum Bit: Int, CaseIterable {
            case negative = 7
            case overflow = 6
            // TODO: Note that `bit5` and `break` apparently don't actually exist in the processor. So is this how we want to model this?
            // See http://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
            case bit5 = 5
            case `break` = 4
            case decimal = 3
            case interruptDisable = 2
            case zero = 1
            case carry = 0
        }
        
        public private(set) var value: UInt8

        public init(integerLiteral value: UInt8) {
            self.value = value
        }
        
        public subscript(processorStatusBit: Bit) -> Bool {
            get { value[processorStatusBit.rawValue] }
            set { value[processorStatusBit.rawValue] = newValue }
        }
    }
}

extension ProcessorState.ProcessorStatusRegister: CustomDebugStringConvertible {
    public var debugDescription: String {
        let bits = (0...7).reversed().map { value[$0] == true ? "1" : "0"  }.joined()
        return "\(value.hexString) \(bits) (NV-BDIZC)"
    }
}
