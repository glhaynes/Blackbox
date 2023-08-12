//
//  Instruction.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 11/29/19.
//  Copyright © 2019 Grady Haynes. All rights reserved.
//

public struct Instruction: Equatable {
    
    let mnemonic: Mnemonic
    let opcode: UInt8
    let addressingMode: AddressingMode
    let size: Int
    let cycleCount: Int

    public enum AddressingMode: Equatable {
        
        // TODO: Add a comment detailing some other names for these
        
        case implied  // A lot of these should really be stack, I think. The ones where the opcode's imp uses the stack pointer...
        case accumulator
        case immediate
        case stack

        case programCounterRelative

        case zeroPage
        case zeroPageIndexedWithX
        case zeroPageIndexedWithY
        case zeroPageIndexedIndirectWithX  // "Preindexed"
        case zeroPageIndirectIndexedWithY  // "Postindexed""

        case absolute
        case absoluteIndexedWithX
        case absoluteIndexedWithY
        case absoluteIndirect  // Only used by JMP (takes the address pointed to by the address pointed to by the op parameter)
    }
    
    public enum Mnemonic: String, Equatable {
        case adc, alr, anc, and, arr, asl, axs, bcc, bcs, beq, bit, bmi, bne, bpl, brk, bvc, bvs, clc, cld, cli, clv, cmp, cpx, cpy, dcp, dec,
             dex, dey, eor, ign, inc, inx, iny, isc, jmp, jsr, lax, lda, ldx, ldy, lsr, nop, ora, pha, php, pla, plp, rla, rol, ror, rra, rti,
             rts, sax, sbc, sec, sed, sei, skb, slo, sre, sta, stx, sty, tax, tay, tsx, txa, txs, tya
    }
}
