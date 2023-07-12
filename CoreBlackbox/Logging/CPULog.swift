//
//  CPULog.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 1/20/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation

public enum CPULog {
    
    public enum MemoryAccessDetails {
        case read(from: UInt16, value: UInt8)
        case write(to: UInt16, value: UInt8, replacing: UInt8)
    }
    
    public enum InterruptDetails {
        case nonMaskable
        case maskable(isMasked: Bool)
    }
    
    case cpuState(ProcessorState)
    case instruction(Instruction)
    case memoryAccess(MemoryAccessDetails)
    case interrupt(InterruptDetails)
    case reset
    //case other
    
    var string: String {
        ""  // TODO: Fix this
    }
}

extension CPULog: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .cpuState(let state):
            return "\(state)"
        case .instruction(let instruction):
            return "\(instruction)"
        case .memoryAccess(let details):
            switch details {
            case .read(from: let address, value: let value):
                return "MEMORY - READ from \(address.hexString), value: \(value.hexString) (\(value)))"
            case .write(to: let address, value: let value, replacing: let replacing):
                return "MEMORY - WRITE to  \(address.hexString), value: \(value.hexString) (\(value)), replacing: \(replacing) (\(replacing.hexString))"
            }
        case .interrupt(let details):
            return "\(details)"
        case .reset:
            return "Reset"
        }
    }
}
