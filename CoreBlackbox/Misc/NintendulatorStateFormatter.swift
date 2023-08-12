//
//  NintendulatorStateFormatter.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/3/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation

// FIXME: Rename - Not really a formatter since it captures data from the bus
struct NintendulatorStateFormatter {
    
    struct FormattedFields {
        let busCyclesCompleted: UInt64
        let lineNumber: UInt64
        let fPC: String
        let fBytes: String
        let fInstruction: String
        let fA: String
        let fX: String
        let fY: String
        let fP: String
        let fSP: String
        let fPPU: String
        let fCyc: String
    }

    let bus: NESBus
    var lineCount: UInt64 = 0
        
    func formattedFields() -> FormattedFields? {

        let cpu = bus.cpu
        let ppu = bus.ppu
        
        let pc = cpu.processorState.pc
                
        guard let instruction = try? InstructionDecoder.decodeInstruction(bus: bus, pc: cpu.processorState.pc) else {
            return nil  // TODO: Maybe throw instead
        }
        
        let fPC = pc.hexStringWithNoLeading0X.uppercased()
        
        let instructionBytes: [UInt8?] = [
            instruction.size > 0 ? bus.read(from: pc) : nil,
            instruction.size > 1 ? bus.read(from: pc &+ 1) : nil,
            instruction.size > 2 ? bus.read(from: pc &+ 2) : nil,
        ]

        let fBytes = instructionBytes.map { $0 == nil ? "  " : $0!.hexStringWithNoLeading0X.uppercased() }.joined(separator: " ")

        let fParameters = {
            var ret = ""
            if instruction.size > 1 {
                switch instruction.addressingMode {
                case .implied, .accumulator, .immediate, .stack, .programCounterRelative, .zeroPage, .zeroPageIndexedWithX, .zeroPageIndexedWithY, .zeroPageIndexedIndirectWithX, .zeroPageIndirectIndexedWithY, .absolute, .absoluteIndexedWithX, .absoluteIndexedWithY, .absoluteIndirect:
                    ret += "$"
                    // ...
                }
                
                if instruction.size > 2 {
                    ret += instructionBytes[2]!.hexStringWithNoLeading0X.uppercased()
                }
                
                ret += instructionBytes[1]!.hexStringWithNoLeading0X.uppercased()
            }
            return ret
        }()
                
        let fInstruction = "\(instruction.mnemonic.rawValue.uppercased()) \(fParameters)".padding(toLength: 32, withPad: " ", startingAt: 0)
        
        let fPPU0 = String(ppu.state.scanlineCounter).leftPadding(toLength: 3, withPad: " ")
        let fPPU1 = String(ppu.state.cycleCounter - ppu.state.scanlineCounter * 341).leftPadding(toLength: 3, withPad: " ")
    
        let fields = FormattedFields(
            busCyclesCompleted: bus.cyclesCompleted,
            lineNumber: lineCount,
            fPC: fPC,
            fBytes: fBytes,
            fInstruction: fInstruction,
            fA: "A:\(cpu.processorState.a.hexStringWithNoLeading0X.uppercased())",
            fX: "X:\(cpu.processorState.x.hexStringWithNoLeading0X.uppercased())",
            fY: "Y:\(cpu.processorState.y.hexStringWithNoLeading0X.uppercased())",
            fP: "P:\(cpu.processorState.p.value.hexStringWithNoLeading0X.uppercased())",
            fSP: "SP:\(cpu.processorState.s.hexStringWithNoLeading0X.uppercased())",
            fPPU: "PPU:\(fPPU0),\(fPPU1)",
            fCyc: "CYC: \(cpu.cycleCount)"
        )
        
        return fields
    }
        
    func formattedLine(for fields: FormattedFields) -> String {
        var ret = ""
        ret += "\(fields.lineNumber) ".leftPadding(toLength: 10, withPad: " ")
        ret += "\(fields.fPC)  "
        ret += "\(fields.fBytes)  "
        ret += fields.fInstruction
        ret += fields.fA + " "
        ret += fields.fX + " "
        ret += fields.fY + " "
        ret += fields.fP + " "
        ret += fields.fSP + " "
        ret += fields.fPPU + " "
        ret += fields.fCyc + " "
        return ret
    }
}

// Taken from https://stackoverflow.com/a/69859859/3547802
private extension String {
    func leftPadding(toLength: Int, withPad: String) -> String {
        String(String(reversed()).padding(toLength: toLength, withPad: withPad, startingAt: 0).reversed())
    }
}
