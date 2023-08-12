//
//  InstructionDecoder.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/1/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation

public struct InstructionDecoder {
    
    private static let instructionSet = InstructionSet()
    
    public static func decodeInstruction(bus: Bus, pc: UInt16) throws -> Instruction {
        
        enum Error: Swift.Error, LocalizedError {
            case invalidOpcode(UInt8)
            
            var errorDescription: String? {
                switch self {
                case .invalidOpcode(let opcode):
                    return "Invalid opcode \(opcode)"
                }
            }
        }
        
        let nextOpcode = bus.read(from: pc)
        guard let instruction = Self.instructionSet.instructionForOpcode[nextOpcode] else {
            throw Error.invalidOpcode(nextOpcode)
        }
        return instruction
    }
}
