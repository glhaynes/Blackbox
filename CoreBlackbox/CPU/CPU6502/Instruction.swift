//
//  Instruction.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 11/29/19.
//  Copyright © 2019 Grady Haynes. All rights reserved.
//

public struct Instruction: Equatable {
    
    public enum Mnemonic: String, Equatable {
        case adc
        case alr
        case anc
        case and
        case arr
        case asl
        case axs
        case bcc
        case bcs
        case beq
        case bit
        case bmi
        case bne
        case bpl
        case brk
        case bvc
        case bvs
        case clc
        case cld
        case cli
        case clv
        case cmp
        case cpx
        case cpy
        case dcp
        case dec
        case dex
        case dey
        case eor
        case ign
        case inc
        case inx
        case iny
        case isc
        case jmp
        case jsr
        case lax
        case lda
        case ldx
        case ldy
        case lsr
        case nop
        case ora
        case pha
        case php
        case pla
        case plp
        case rla
        case rol
        case ror
        case rra
        case rti
        case rts
        case sax
        case sbc
        case sec
        case sed
        case sei
        case skb
        case slo
        case sre
        case sta
        case stx
        case sty
        case tax
        case tay
        case tsx
        case txa
        case txs
        case tya
    }

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
    
    let mnemonic: Mnemonic
    let opcode: UInt8
    let addressingMode: AddressingMode
    let size: Int
    let cycleCount: Int  // TODO: This will go away when we become cycle-accurate
}
