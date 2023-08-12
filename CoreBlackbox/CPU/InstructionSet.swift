//
//  InstructionSet.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 11/29/19.
//  Copyright © 2019 Grady Haynes. All rights reserved.
//

public struct InstructionSet {
    
    let instructionForOpcode: [UInt8: Instruction]
        
    init() {
        instructionForOpcode = Dictionary(grouping: Self.instructions) { $0.opcode }.compactMapValues { $0.first! }
    }

    private static let instructions: [Instruction] = [
        
        // ADC:
        Instruction(mnemonic: .adc, opcode: 0x69, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .adc, opcode: 0x65, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .adc, opcode: 0x75, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .adc, opcode: 0x6d, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .adc, opcode: 0x7d, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .adc, opcode: 0x79, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .adc, opcode: 0x61, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .adc, opcode: 0x71, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // AND:
        Instruction(mnemonic: .and, opcode: 0x29, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .and, opcode: 0x25, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .and, opcode: 0x35, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .and, opcode: 0x2d, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .and, opcode: 0x3d, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .and, opcode: 0x39, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .and, opcode: 0x21, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .and, opcode: 0x31, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // ASL:
        Instruction(mnemonic: .asl, opcode: 0x0a, addressingMode: .accumulator, size: 1, cycleCount: 2),
        Instruction(mnemonic: .asl, opcode: 0x06, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .asl, opcode: 0x16, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .asl, opcode: 0x0e, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .asl, opcode: 0x1e, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // BCC:
        Instruction(mnemonic: .bcc, opcode: 0x90, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BCS:
        Instruction(mnemonic: .bcs, opcode: 0xb0, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BEQ:
        Instruction(mnemonic: .beq, opcode: 0xf0, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BIT:
        Instruction(mnemonic: .bit, opcode: 0x24, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .bit, opcode: 0x2c, addressingMode: .absolute, size: 3, cycleCount: 4),

        // BMI:
        Instruction(mnemonic: .bmi, opcode: 0x30, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BNE:
        Instruction(mnemonic: .bne, opcode: 0xd0, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BPL:
        Instruction(mnemonic: .bpl, opcode: 0x10, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BRK:
        Instruction(mnemonic: .brk, opcode: 0x00, addressingMode: .implied, size: 1, cycleCount: 7),

        // BVC:
        Instruction(mnemonic: .bvc, opcode: 0x50, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // BVS:
        Instruction(mnemonic: .bvs, opcode: 0x70, addressingMode: .programCounterRelative, size: 2, cycleCount: 2),

        // CLC:
        Instruction(mnemonic: .clc, opcode: 0x18, addressingMode: .implied, size: 1, cycleCount: 2),

        // CLD:
        Instruction(mnemonic: .cld, opcode: 0xd8, addressingMode: .implied, size: 1, cycleCount: 2),

        // CLI:
        Instruction(mnemonic: .cli, opcode: 0x58, addressingMode: .implied, size: 1, cycleCount: 2),

        // CLV:
        Instruction(mnemonic: .clv, opcode: 0xb8, addressingMode: .implied, size: 1, cycleCount: 2),

        // CMP:
        Instruction(mnemonic: .cmp, opcode: 0xc9, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .cmp, opcode: 0xc5, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .cmp, opcode: 0xd5, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .cmp, opcode: 0xcd, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .cmp, opcode: 0xdd, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .cmp, opcode: 0xd9, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .cmp, opcode: 0xc1, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .cmp, opcode: 0xd1, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // CPX:
        Instruction(mnemonic: .cpx, opcode: 0xe0, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .cpx, opcode: 0xe4, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .cpx, opcode: 0xec, addressingMode: .absolute, size: 3, cycleCount: 4),

        // CPY:
        Instruction(mnemonic: .cpy, opcode: 0xc0, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .cpy, opcode: 0xc4, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .cpy, opcode: 0xcc, addressingMode: .absolute, size: 3, cycleCount: 4),

        // DEC:
        Instruction(mnemonic: .dec, opcode: 0xc6, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .dec, opcode: 0xd6, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .dec, opcode: 0xce, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .dec, opcode: 0xde, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // DEX:
        Instruction(mnemonic: .dex, opcode: 0xca, addressingMode: .implied, size: 1, cycleCount: 2),

        // DEY:
        Instruction(mnemonic: .dey, opcode: 0x88, addressingMode: .implied, size: 1, cycleCount: 2),

        // EOR:
        Instruction(mnemonic: .eor, opcode: 0x49, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .eor, opcode: 0x45, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .eor, opcode: 0x55, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .eor, opcode: 0x4d, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .eor, opcode: 0x5d, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .eor, opcode: 0x59, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .eor, opcode: 0x41, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .eor, opcode: 0x51, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // INC:
        Instruction(mnemonic: .inc, opcode: 0xe6, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .inc, opcode: 0xf6, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .inc, opcode: 0xee, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .inc, opcode: 0xfe, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // INX:
        Instruction(mnemonic: .inx, opcode: 0xe8, addressingMode: .implied, size: 1, cycleCount: 2),

        // INY:
        Instruction(mnemonic: .iny, opcode: 0xc8, addressingMode: .implied, size: 1, cycleCount: 2),

        // JMP:
        Instruction(mnemonic: .jmp, opcode: 0x4c, addressingMode: .absolute, size: 3, cycleCount: 3),
        Instruction(mnemonic: .jmp, opcode: 0x6c, addressingMode: .absoluteIndirect, size: 3, cycleCount: 5),

        // JSR:
        Instruction(mnemonic: .jsr, opcode: 0x20, addressingMode: .absolute, size: 3, cycleCount: 6),

        // LDA:
        Instruction(mnemonic: .lda, opcode: 0xa9, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .lda, opcode: 0xa5, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .lda, opcode: 0xb5, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .lda, opcode: 0xad, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .lda, opcode: 0xbd, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .lda, opcode: 0xb9, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .lda, opcode: 0xa1, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .lda, opcode: 0xb1, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // LDX:
        Instruction(mnemonic: .ldx, opcode: 0xa2, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .ldx, opcode: 0xa6, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .ldx, opcode: 0xb6, addressingMode: .zeroPageIndexedWithY, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ldx, opcode: 0xae, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ldx, opcode: 0xbe, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),

        // LDY:
        Instruction(mnemonic: .ldy, opcode: 0xa0, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .ldy, opcode: 0xa4, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .ldy, opcode: 0xb4, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ldy, opcode: 0xac, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ldy, opcode: 0xbc, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),

        // LSR:
        Instruction(mnemonic: .lsr, opcode: 0x4a, addressingMode: .accumulator, size: 1, cycleCount: 2),
        Instruction(mnemonic: .lsr, opcode: 0x46, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .lsr, opcode: 0x56, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .lsr, opcode: 0x4e, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .lsr, opcode: 0x5e, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // NOP:
        Instruction(mnemonic: .nop, opcode: 0x1a, addressingMode: .implied, size: 1, cycleCount: 2),
        Instruction(mnemonic: .nop, opcode: 0x3a, addressingMode: .implied, size: 1, cycleCount: 2),
        Instruction(mnemonic: .nop, opcode: 0x5a, addressingMode: .implied, size: 1, cycleCount: 2),
        Instruction(mnemonic: .nop, opcode: 0x7a, addressingMode: .implied, size: 1, cycleCount: 2),
        Instruction(mnemonic: .nop, opcode: 0xda, addressingMode: .implied, size: 1, cycleCount: 2),
        Instruction(mnemonic: .nop, opcode: 0xea, addressingMode: .implied, size: 1, cycleCount: 2),
        Instruction(mnemonic: .nop, opcode: 0xfa, addressingMode: .implied, size: 1, cycleCount: 2),

        // ORA:
        Instruction(mnemonic: .ora, opcode: 0x09, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .ora, opcode: 0x05, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .ora, opcode: 0x15, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ora, opcode: 0x0d, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ora, opcode: 0x1d, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ora, opcode: 0x19, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ora, opcode: 0x01, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .ora, opcode: 0x11, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // PHA:
        Instruction(mnemonic: .pha, opcode: 0x48, addressingMode: .implied, size: 1, cycleCount: 3),

        // PHP:
        Instruction(mnemonic: .php, opcode: 0x08, addressingMode: .implied, size: 1, cycleCount: 3),

        // PLA:
        Instruction(mnemonic: .pla, opcode: 0x68, addressingMode: .implied, size: 1, cycleCount: 4),

        // PLP:
        Instruction(mnemonic: .plp, opcode: 0x28, addressingMode: .implied, size: 1, cycleCount: 4),

        // ROL:
        Instruction(mnemonic: .rol, opcode: 0x2a, addressingMode: .accumulator, size: 1, cycleCount: 2),
        Instruction(mnemonic: .rol, opcode: 0x26, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .rol, opcode: 0x36, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .rol, opcode: 0x2e, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .rol, opcode: 0x3e, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // ROR:
        Instruction(mnemonic: .ror, opcode: 0x6a, addressingMode: .accumulator, size: 1, cycleCount: 2),
        Instruction(mnemonic: .ror, opcode: 0x66, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .ror, opcode: 0x76, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .ror, opcode: 0x6e, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .ror, opcode: 0x7e, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // RTI:
        Instruction(mnemonic: .rti, opcode: 0x40, addressingMode: .implied, size: 1, cycleCount: 6),

        // RTS:
        Instruction(mnemonic: .rts, opcode: 0x60, addressingMode: .implied, size: 1, cycleCount: 6),

        // SBC:
        Instruction(mnemonic: .sbc, opcode: 0xe9, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .sbc, opcode: 0xe5, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .sbc, opcode: 0xf5, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .sbc, opcode: 0xed, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .sbc, opcode: 0xfd, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .sbc, opcode: 0xf9, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),
        Instruction(mnemonic: .sbc, opcode: 0xe1, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .sbc, opcode: 0xf1, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),

        // TODO: Adding this to pass Nestest. No idea what the values should be...
        // TODO: Note that the above SBCs don't seem to match what's on here: https://www.masswerk.at/nowgobang/2021/6502-illegal-opcodes
        Instruction(mnemonic: .sbc, opcode: 0xeb, addressingMode: .immediate, size: 2, cycleCount: 2),
        
        
        // SEC:
        Instruction(mnemonic: .sec, opcode: 0x38, addressingMode: .implied, size: 1, cycleCount: 2),

        // SED:
        Instruction(mnemonic: .sed, opcode: 0xf8, addressingMode: .implied, size: 1, cycleCount: 2),

        // SEI:
        Instruction(mnemonic: .sei, opcode: 0x78, addressingMode: .implied, size: 1, cycleCount: 2),

        // STA:
        Instruction(mnemonic: .sta, opcode: 0x85, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .sta, opcode: 0x95, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .sta, opcode: 0x8d, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .sta, opcode: 0x9d, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 5),
        Instruction(mnemonic: .sta, opcode: 0x99, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 5),
        Instruction(mnemonic: .sta, opcode: 0x81, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .sta, opcode: 0x91, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 6),

        // STX:
        Instruction(mnemonic: .stx, opcode: 0x86, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .stx, opcode: 0x96, addressingMode: .zeroPageIndexedWithY, size: 2, cycleCount: 4),
        Instruction(mnemonic: .stx, opcode: 0x8e, addressingMode: .absolute, size: 3, cycleCount: 4),

        // STY:
        Instruction(mnemonic: .sty, opcode: 0x84, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .sty, opcode: 0x94, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .sty, opcode: 0x8c, addressingMode: .absolute, size: 3, cycleCount: 4),

        // TAX:
        Instruction(mnemonic: .tax, opcode: 0xaa, addressingMode: .implied, size: 1, cycleCount: 2),

        // TAY:
        Instruction(mnemonic: .tay, opcode: 0xa8, addressingMode: .implied, size: 1, cycleCount: 2),

        // TSX:
        Instruction(mnemonic: .tsx, opcode: 0xba, addressingMode: .implied, size: 1, cycleCount: 2),

        // TXA:
        Instruction(mnemonic: .txa, opcode: 0x8a, addressingMode: .implied, size: 1, cycleCount: 2),

        // TXS:
        Instruction(mnemonic: .txs, opcode: 0x9a, addressingMode: .implied, size: 1, cycleCount: 2),

        // TYA:
        Instruction(mnemonic: .tya, opcode: 0x98, addressingMode: .implied, size: 1, cycleCount: 2),

        // ALR:
        Instruction(mnemonic: .alr, opcode: 0x4b, addressingMode: .immediate, size: 2, cycleCount: 2),

        // ANC:
        Instruction(mnemonic: .anc, opcode: 0x0b, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .anc, opcode: 0x2b, addressingMode: .immediate, size: 2, cycleCount: 2),

        // ARR:
        Instruction(mnemonic: .arr, opcode: 0x6b, addressingMode: .immediate, size: 2, cycleCount: 2),

        // AXS:
        Instruction(mnemonic: .axs, opcode: 0xcb, addressingMode: .immediate, size: 2, cycleCount: 2),

        // LAX:
        Instruction(mnemonic: .lax, opcode: 0xa3, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .lax, opcode: 0xa7, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .lax, opcode: 0xaf, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .lax, opcode: 0xb3, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 5),
        Instruction(mnemonic: .lax, opcode: 0xb7, addressingMode: .zeroPageIndexedWithY, size: 2, cycleCount: 4),
        Instruction(mnemonic: .lax, opcode: 0xbf, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 4),

        // SAX:
        Instruction(mnemonic: .sax, opcode: 0x83, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .sax, opcode: 0x87, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .sax, opcode: 0x8f, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .sax, opcode: 0x97, addressingMode: .zeroPageIndexedWithY, size: 2, cycleCount: 4),

        // DCP:
        Instruction(mnemonic: .dcp, opcode: 0xc3, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 8),
        Instruction(mnemonic: .dcp, opcode: 0xc7, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .dcp, opcode: 0xcf, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .dcp, opcode: 0xd3, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 8),
        Instruction(mnemonic: .dcp, opcode: 0xd7, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .dcp, opcode: 0xdb, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 7),
        Instruction(mnemonic: .dcp, opcode: 0xdf, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // ISC:
        Instruction(mnemonic: .isc, opcode: 0xe3, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 8),
        Instruction(mnemonic: .isc, opcode: 0xe7, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .isc, opcode: 0xef, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .isc, opcode: 0xf3, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 8),
        Instruction(mnemonic: .isc, opcode: 0xf7, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .isc, opcode: 0xfb, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 7),
        Instruction(mnemonic: .isc, opcode: 0xff, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // RLA:
        Instruction(mnemonic: .rla, opcode: 0x23, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 8),
        Instruction(mnemonic: .rla, opcode: 0x27, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .rla, opcode: 0x2f, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .rla, opcode: 0x33, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 8),
        Instruction(mnemonic: .rla, opcode: 0x37, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .rla, opcode: 0x3b, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 7),
        Instruction(mnemonic: .rla, opcode: 0x3f, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // RRA:
        Instruction(mnemonic: .rra, opcode: 0x63, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 8),
        Instruction(mnemonic: .rra, opcode: 0x67, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .rra, opcode: 0x6f, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .rra, opcode: 0x73, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 8),
        Instruction(mnemonic: .rra, opcode: 0x77, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .rra, opcode: 0x7b, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 7),
        Instruction(mnemonic: .rra, opcode: 0x7f, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // SLO:
        Instruction(mnemonic: .slo, opcode: 0x03, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 8),
        Instruction(mnemonic: .slo, opcode: 0x07, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .slo, opcode: 0x0f, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .slo, opcode: 0x13, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 8),
        Instruction(mnemonic: .slo, opcode: 0x17, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .slo, opcode: 0x1b, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 7),
        Instruction(mnemonic: .slo, opcode: 0x1f, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // SRE:
        Instruction(mnemonic: .sre, opcode: 0x43, addressingMode: .zeroPageIndexedIndirectWithX, size: 2, cycleCount: 8),
        Instruction(mnemonic: .sre, opcode: 0x47, addressingMode: .zeroPage, size: 2, cycleCount: 5),
        Instruction(mnemonic: .sre, opcode: 0x4f, addressingMode: .absolute, size: 3, cycleCount: 6),
        Instruction(mnemonic: .sre, opcode: 0x53, addressingMode: .zeroPageIndirectIndexedWithY, size: 2, cycleCount: 8),
        Instruction(mnemonic: .sre, opcode: 0x57, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 6),
        Instruction(mnemonic: .sre, opcode: 0x5b, addressingMode: .absoluteIndexedWithY, size: 3, cycleCount: 7),
        Instruction(mnemonic: .sre, opcode: 0x5f, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 7),

        // SKB:
        Instruction(mnemonic: .skb, opcode: 0x80, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .skb, opcode: 0x82, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .skb, opcode: 0x89, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .skb, opcode: 0xc2, addressingMode: .immediate, size: 2, cycleCount: 2),
        Instruction(mnemonic: .skb, opcode: 0xe2, addressingMode: .immediate, size: 2, cycleCount: 2),

        // IGN:
        Instruction(mnemonic: .ign, opcode: 0x0c, addressingMode: .absolute, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x1c, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x3c, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x5c, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x7c, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0xdc, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0xfc, addressingMode: .absoluteIndexedWithX, size: 3, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x04, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .ign, opcode: 0x44, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .ign, opcode: 0x64, addressingMode: .zeroPage, size: 2, cycleCount: 3),
        Instruction(mnemonic: .ign, opcode: 0x14, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x34, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x54, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0x74, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0xd4, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4),
        Instruction(mnemonic: .ign, opcode: 0xf4, addressingMode: .zeroPageIndexedWithX, size: 2, cycleCount: 4)
    ]
}
