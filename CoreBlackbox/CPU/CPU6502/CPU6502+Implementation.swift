//
//  CPU6502+Implementations.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 1/2/21.
//  Copyright © 2021 Grady Haynes. All rights reserved.
//

import Foundation

extension CPU6502 {

    // TODO: Distribute these back
    static let nz: [ProcessorState.ProcessorStatusRegister.Bit] = [.negative, .zero]
    static let nzc: [ProcessorState.ProcessorStatusRegister.Bit] = [.negative, .zero, .carry]
    static let noz: [ProcessorState.ProcessorStatusRegister.Bit] = [.negative, .overflow, .zero]
    static let nozc: [ProcessorState.ProcessorStatusRegister.Bit] = [.negative, .overflow, .zero, .carry]

    // Lots of good information on illegal opcodes here: https://www.masswerk.at/nowgobang/2021/6502-illegal-opcodes
        
    func execute(mnemonic: Instruction.Mnemonic,
                 addressingMode: Instruction.AddressingMode,
                 parameterAddress address: UInt16?
    ) {
        // Illegal instructions tend to be basically just combinations of existing ones
        func illegalInstructionHelper(_ mnemonics: Instruction.Mnemonic...) {
            mnemonics.forEach {
                execute(mnemonic: $0, addressingMode: addressingMode, parameterAddress: address)
            }
        }

        switch mnemonic {
        // ADC - Add With Carry
        case .adc:
            let isDecimal = processorState.p[.decimal] && isRespectingDecimalMode
            
            let valueInA = isDecimal ?
                UInt16(processorState.a).asBCDValue :
                UInt16(processorState.a)
            let valueInMemory = isDecimal ?
                UInt16(bus!.load8(from: address!)).asBCDValue :
                UInt16(bus!.load8(from: address!))
            
            var sum = valueInA + valueInMemory + (processorState.p[.carry] ? 1 : 0)
            
            if isDecimal {
                if sum >= 100 {
                    sum -= 100
                    processorState.p[.carry] = true
                }
                else {
                    processorState.p[.carry] = false
                }
                sum = sum.bcdAsHexValue
            }
            
            let flags: [ProcessorState.ProcessorStatusRegister.Bit] = isDecimal ? Self.noz : Self.nozc
            
            
            updateProcessorStatus(calculatedValue: sum, memoryValue: valueInMemory.lowByte, flags: flags)
            processorState.a = sum.lowByte

        case .alr:
            fatalError()

        case .anc:
            fatalError()

        // AND - And Accumulator with Memory
        case .and:
            let newValue = processorState.a & bus!.load8(from: address!)
            processorState.a = newValue
            updateProcessorStatus(calculatedValue: UInt16(newValue), flags: Self.nz)
        
        case .arr:
            fatalError()
        
        // ASL - Arithmetic Shift Left
        case .asl:
            
            // TODO: This sucks that we have to `if` here
            
            switch addressingMode {
            case .accumulator:
                let result = UInt16(processorState.a) << 1
                processorState.a = result.lowByte
                updateProcessorStatus(calculatedValue: result, flags: Self.nzc)
            // TODO: Would be nice to explicitly state the others here and fail on `default`
            default:
                let result = UInt16(bus!.load8(from: address!)) << 1
                write(result.lowByte, to: address!)
                updateProcessorStatus(calculatedValue: result, flags: Self.nzc)
            }

        case .axs:
            fatalError()

        // BCC - Branch if Carry Clear
        case .bcc:
            guard !processorState.p[.carry] else { return }
            processorState.pc = address!

        // BCS - Branch if Carry Set
        case .bcs:
            guard processorState.p[.carry] else { return }
            processorState.pc = address!
        
        // BEQ - Branch if Equal
        case .beq:
            guard processorState.p[.zero] else { return }
            processorState.pc = address!
            // TODO: Add some clocks if old PC had any high-bits set (?)

        // BIT - Test Memory Bits against Accumulator
        case .bit:

            let value = bus!.load8(from: address!)
            let result = UInt16(processorState.a) & UInt16(value)
            
            let zero = result == 0

            switch addressingMode {
            case .immediate:
                processorState.p[.zero] = zero
            default:
                let negative = value[7]
                let overflow = value[6]

                processorState.p[.negative] = negative
                processorState.p[.overflow] = overflow
                processorState.p[.zero] = zero
            }
    //            switch instruction.addressingMode {
    //            case .immediate:
    //                changes += processorStatusChangesFor(computer: computer, calculatedValue: result, memoryValue: value, flags: [.zero])
    //            default:
    //                changes += processorStatusChangesFor(computer: computer, calculatedValue: result, memoryValue: value, flags: Self.noz)
    //            }
        
        // BMI - Branch if Minus
        case .bmi:
            guard processorState.p[.negative] else { return }
            processorState.pc = address!
        
        // BNE - Branch if Not Equal
        case .bne:
            guard !processorState.p[.zero] else { return }
            processorState.pc = address!
        
        // BPL - Branch if Plus
        case .bpl:
            guard !processorState.p[.negative] else { return }
            processorState.pc = address!
        
        // BRK - Break
        case .brk:
            
            let stackAddress = stackAddressFor(lowByte: processorState.s)
            
            let newPC = processorState.pc &+ 1  // TODO: Thought this was supposed to be 2 but 1 gets me further… oh I bet it's because of the 1 byte BRK - we've already been incremented by that 1 before we get to here, so we just need 1 more...
            
            var newStatus = processorState.p
            newStatus[.break] = true  // TODO: Doesn't seem like this matches what's in the docs, but the tests want it...
            newStatus[.bit5] = true  // FIXME: Probably not needed; probably should be removed
            //newStatus[.interruptDisable] = true
            
            processorState.pc = newPC
            write(newPC.highByte, to: stackAddress)
            write(newPC.lowByte, to: stackAddress &- 1)
            write(newStatus.value, to: stackAddress &- 2)
            processorState.s = processorState.s &- 3
            //.processorStatus(.bit5, true),  // TODO: Should this be here?
            processorState.p[.interruptDisable] = true
            processorState.pc = bus!.load16(from: 0xfffe)
            processorState.isHalted = true  // TODO: This was commented out earlier…
            
            // TODO: Need to increment cyclesSpent? Or do anything else?    }
        
        // BVC - Branch if Overflow Clear
        case .bvc:
            guard !processorState.p[.overflow] else { return }
            processorState.pc = address!
        
        // BVS - Branch if Overflow Set
        case .bvs:
            guard processorState.p[.overflow] else { return }
            processorState.pc = address!
        
        // CLC - Clear Carry
        case .clc:
            processorState.p[.carry] = false
        
        // CLD - Clear Decimal Mode Flag
        case .cld:
            processorState.p[.decimal] = false
        
        // CLI - Clear Interrupt Disable Flag
        case .cli:
            processorState.p[.interruptDisable] = false
        
        // CLV - Clear Overflow
        case .clv:
            processorState.p[.overflow] = false
        
        // CMP - Compare Accumulator with Memory
        case .cmp:
            let result = UInt16(processorState.a) &- UInt16(bus!.load8(from: address!))
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
            // Calculate carry
            let newCarry = UInt16(processorState.a) >= UInt16(bus!.load8(from: address!))
            processorState.p[.carry] = newCarry
        
        // CPX - Compare Index Register X with Memory
        case .cpx:
            let result = UInt16(processorState.x) &- UInt16(bus!.load8(from: address!))
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
            // Calculate carry
            let newCarry = UInt16(processorState.x) >= UInt16(bus!.load8(from: address!))
            processorState.p[.carry] = newCarry
        
        // CPY - Compare Index Register Y with Memory
        case .cpy:
            let result = UInt16(processorState.y) &- UInt16(bus!.load8(from: address!))
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
            // Calculate carry
            let newCarry = UInt16(processorState.y) >= UInt16(bus!.load8(from: address!))
            processorState.p[.carry] = newCarry
        
        // TODO: ??
        case .dcp:
            // "Equivalent to DEC value then CMP value, except supporting more addressing modes. LDA #$FF followed by DCP can be used to check if the decrement underflows, which is useful for multi-byte decrements."
            illegalInstructionHelper(.dec, .cmp)
        
        // DEC - Decrement
        case .dec:
            // TODO: This needs to handle DEC A (0x3a). Surprised we're not ever hitting that, but I guess we aren't since we're not crashing.
            let value = UInt16(bus!.load8(from: address!))
            let result = value &- 1
            write(result.lowByte, to: address!)
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
        
        // DEX - Decrement Index Register X
        case .dex:
            let result = processorState.x &- 1
            processorState.x = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)
        
        // DEY - Decrement Index Register Y
        case .dey:
            let result = processorState.y &- 1
            processorState.y = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)
        
        // EOR - Exclusive-OR Accumulator with Memory
        case .eor:
            let result = processorState.a ^ bus!.load8(from: address!)
            processorState.a = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)
        
        case .ign:
            // Undocumented instruction
            // "Reads from memory at the specified address and ignores the value. Affects no register nor flags. The absolute version can be used to increment PPUADDR or reset the PPUSTATUS latch as an alternative to BIT. The zero page version has no side effects.
            // "IGN d,X reads from both d and (d+X)&255. IGN a,X additionally reads from a+X-256 it crosses a page boundary (i.e. if ((a & 255) + X) > 255)
            // "Sometimes called TOP (triple-byte no-op), SKW (skip word), DOP (double-byte no-op), or SKB (skip byte)."
            break
        
        // INC - Increment
        case .inc:
            // Note: Seems like this should have carry, but it doesn't (see docs)
            let result = UInt16(bus!.load8(from: address!)) + 1
            write(result.lowByte, to: address!)
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
        
        // INX - Increment Index Register X
        case .inx:
            let result = UInt16(processorState.x) + 1
            processorState.x = result.lowByte
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
        
        // INY - Increment Index Register Y
        case .iny:
            let result = UInt16(processorState.y) + 1
            processorState.y = result.lowByte
            updateProcessorStatus(calculatedValue: result, flags: Self.nz)
        
        // TODO: ??
        case .isc:
            // "Equivalent to INC value then SBC value, except supporting more addressing modes."
            illegalInstructionHelper(.inc, .sbc)
        
        // JMP - Jump
        case .jmp:
            processorState.pc = address!

        // JSR - Jump to Subroutine
        case .jsr:
            let returnAddress = processorState.pc &- 1  // The "&- 1" is to adjust to follow the docs which say that when this gets pulled back (via RTS), one will be added to the result"... so we want old PC + 2 even though it's been moved ahead already by 3 (because this is a 3 byte instruction (JSR #absolute)
            let stackAddress = stackAddressFor(lowByte: processorState.s)
            write(returnAddress.highByte, to: stackAddress)
            write(returnAddress.lowByte, to: stackAddress &- 1)
            processorState.s = processorState.s &- 2
            processorState.pc = address!
        
        // TODO: Document this "extra" instruction
        case .lax:
            // LAX $8400,Y ==
            // LDA $8400,Y
            // LDX $8400,Y
            let value = bus!.load8(from: address!)
            processorState.a = value
            processorState.x = value
            updateProcessorStatus(calculatedValue: UInt16(value), flags: Self.nz)
        
        // LDA - Load Accumulator from Memory
        case .lda:
            let value = bus!.load8(from: address!)
            processorState.a = value
            updateProcessorStatus(calculatedValue: UInt16(value), flags: Self.nz)

        // LDX - Load Index Register X from Memory
        case .ldx:
            let value = bus!.load8(from: address!)
            processorState.x = value
            updateProcessorStatus(calculatedValue: UInt16(value), flags: Self.nz)

        // LDY - Load Index Register Y from Memory
        case .ldy:
            let value = bus!.load8(from: address!)
            processorState.y = value
            updateProcessorStatus(calculatedValue: UInt16(value), flags: Self.nz)

        // LSR - Logical Shift Right
        case .lsr:
            switch addressingMode {
            case .accumulator:
                let value = processorState.a
                let result = value >> 1
                let shiftedOutAOne = value & 1 == 1
                processorState.a = result
                updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nzc)
                // If the original value had a 1 in the Ones spot and it got shifted out, stick it in the carry.
                // TODO: Bummer that we don't have this covered in the above...
                processorState.p[.carry] = shiftedOutAOne
            default:
                let value = bus!.load8(from: address!)
                let result = value >> 1
                let shiftedOutAOne = value & 1 == 1
                write(result, to: address!)
                updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nzc)
                // If the original value had a 1 in the Ones spot and it got shifted out, stick it in the carry.
                // TODO: Bummer that we don't have this covered in the above...
                processorState.p[.carry] = shiftedOutAOne
            }

        // NOP - No Operation
        case .nop:
            break

        // ORA - OR Accumulator with Memory
        case .ora:
            let value = bus!.load8(from: address!)
            let result = processorState.a | value
            processorState.a = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)

        // PHA - Push Accumulator
        case .pha:
            write(processorState.a, to: stackAddressFor(lowByte: processorState.s))
            processorState.s = processorState.s &- 1

        // PHP - Push Processor Status Register
        case .php:
            var p = processorState.p
            // Note: Bits 4 and 5 need to be set when we push P from PHP - see http://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
            p[.break] = true
            p[.bit5] = true  // FIXME: Probably not needed; probably should be removed
            write(p.value, to: stackAddressFor(lowByte: processorState.s))
            processorState.s = processorState.s &- 1

        // TODO: What about PHX / PHY, PLX / PLY? What processors are they available on?
        
        // PLA - Pull Accumulator
        case .pla:
            let pulledValue = bus!.load8(from: stackAddressFor(lowByte: processorState.s &+ 1))
            processorState.a = pulledValue
            processorState.s = processorState.s &+ 1
            updateProcessorStatus(calculatedValue: UInt16(pulledValue), flags: Self.nz)

        // PLP - Pull Status Flags
        case .plp:
            let newP = bus!.load8(from: stackAddressFor(lowByte: processorState.s &+ 1))
            processorState.p[.negative] = newP[7]
            processorState.p[.overflow] = newP[6]
            
            // Confirm we're doing the right thing and then add a note about this. See https://stackoverflow.com/questions/52017657/6502-emulator-testing-nestest#52021545
            //processorState.p[.bit5] = newP[5]
            //processorState.p[.break] = newP[4]
            //processorState.p[.bit5] = false
            processorState.p[.break] = false
            
            processorState.p[.decimal] = newP[3]
            processorState.p[.interruptDisable] = newP[2]
            processorState.p[.zero] = newP[1]
            processorState.p[.carry] = newP[0]
            processorState.s = processorState.s &+ 1

        case .rla:
            // "Equivalent to ROL value then AND value, except supporting more addressing modes. LDA #$FF followed by RLA is an efficient way to rotate a variable while also loading it in A."
            illegalInstructionHelper(.rol, .and)

        // ROL - Rotate Memory or Accumulator Left
        case .rol:
            switch addressingMode {
            case .accumulator:
                let value = processorState.a
                let carry: UInt16 = processorState.p[.carry] ? 1 : 0
                let result = UInt16(value) << 1 | carry
                processorState.a = result.lowByte
                updateProcessorStatus(calculatedValue: result, flags: Self.nzc)
            default:
                let value = bus!.load8(from: address!)
                let carry: UInt16 = processorState.p[.carry] ? 1 : 0
                let result = UInt16(value) << 1 | carry
                write(result.lowByte, to: address!)
                updateProcessorStatus(calculatedValue: result, flags: Self.nzc)
            }

        // ROR - Rotate Right
        case .ror:
            switch addressingMode {
            case .accumulator:
                let value = UInt16(processorState.a)
                let carry: UInt16 = processorState.p[.carry] ? 1 : 0
                let result = value >> 1 | carry << 7
                // If the original value had a 1 in the Ones spot and it got shifted out, stick it in the carry.
                // TODO: Bummer that we don't have this covered in the above...
                let shiftedOutAOne = value & 1 == 1
                processorState.a = result.lowByte
                updateProcessorStatus(calculatedValue: result, flags: Self.nz)
                processorState.p[.carry] = shiftedOutAOne
            
            default:
                let value = UInt16(bus!.load8(from: address!))
                let carry: UInt16 = processorState.p[.carry] ? 1 : 0
                let result = value >> 1 | carry << 7
                // If the original value had a 1 in the Ones spot and it got shifted out, stick it in the carry.
                // TODO: Bummer that we don't have this covered in the above...
                let shiftedOutAOne = value & 1 == 1
                write(result.lowByte, to: address!)
                updateProcessorStatus(calculatedValue: result, flags: Self.nz)
                processorState.p[.carry] = shiftedOutAOne
            }

        case .rra:
            // "Equivalent to ROR value then ADC value, except supporting more addressing modes. Essentially this computes A + value / 2, where value is 9-bit and the division is rounded up."
            illegalInstructionHelper(.ror, .adc)

        // RTI - Return from Interrupt
        case .rti:
            // TODO: Interesting that this is listed as ".stack" in the manual... but we haven't implemented that...
            let newP = bus!.load8(from: stackAddressFor(lowByte: processorState.s &+ 1))
            let newPC = bus!.load16(from: stackAddressFor(lowByte: processorState.s &+ 2))
            
            processorState.p[.negative] = newP[7]
            processorState.p[.overflow] = newP[6]
            //processorState.p[.bit5] = newP[5]  // TODO: Does this make sense?
            processorState.p[.break] = newP[4]
            processorState.p[.decimal] = newP[3]
            processorState.p[.interruptDisable] = newP[2]
            processorState.p[.zero] = newP[1]
            processorState.p[.carry] = newP[0]
            processorState.pc = newPC
            processorState.s = processorState.s &+ 3

        // RTS - Return from Subroutine
        case .rts:
            let returnAddress = bus!.load16(from: stackAddressFor(lowByte: processorState.s &+ 1)) &+ 1  // Add one more on to here so we'll start at the next instruction ... // TODO: Is this right?  Seems like we'd just push the right thing onto the stack in the first place?  But I guess not (so we are right), since the tests pass.
            processorState.pc = returnAddress
            processorState.s = processorState.s &+ 2

        case .sax:
            // TODO: Undocumented instruction: "Stores the bitwise AND of A and X. As with STA and STX, no flags are affected."
            let value = processorState.a & processorState.x
            write(value, to: address!)

        // SBC - Subtract with Borrow from Accumulator
        case .sbc:
            
            // TODO: Reimplement as just a variant of ADC?  https://ltriant.github.io/2019/11/22/nes-emulator.html
            
            let isDecimal = processorState.p[.decimal] && isRespectingDecimalMode
            
            if isDecimal {
            
                let valueInA = isDecimal ?
                    UInt16(processorState.a).asBCDValue :
                    UInt16(processorState.a)
                let valueInMemory = isDecimal ?
                    UInt16(bus!.load8(from: address!)).asBCDValue :
                    UInt16(bus!.load8(from: address!))

                let carry: UInt16 = processorState.p[.carry] ? 0 : 1
                
                var sum = valueInA &- valueInMemory &- carry
                
                if isDecimal {
                    if sum > 0x99 {
                        //sum = (~(sum & 0x00ff) & 0x00ff) //+ 1 //100 - sum
                        sum = 100 - ((0xffff - sum) + 1)
                        processorState.p[.carry] = false
                    }
                    else {
                        processorState.p[.carry] = true
                    }
                    sum = sum.bcdAsHexValue
                }
                            
                if isDecimal {
                    updateProcessorStatus(calculatedValue: sum, memoryValue: valueInMemory.lowByte, flags: Self.noz)
                } else {
                    updateProcessorStatus(calculatedValue: sum, memoryValue: valueInMemory.lowByte, flags: Self.nozc)
                }
                
                processorState.a = sum.lowByte
                
            } else {
            
    //
    //            // Stolen from ADC, only added a "~"!
    //            let isDecimal = processorState.p[.decimal]
    //
                let valueInA = isDecimal ?
                    UInt16(processorState.a).asBCDValue :
                    UInt16(processorState.a)
                // !! Note ~'s here               <<<<-------------
                let valueInMemory = isDecimal ?
                    UInt16(~bus!.load8(from: address!)).asBCDValue :
                    UInt16(~bus!.load8(from: address!))

                let carry: UInt16 = processorState.p[.carry] ? 1 : 0

                var sum = valueInA + valueInMemory + carry

                if isDecimal {
                    if sum > 100 {
                        sum -= 100
                        processorState.p[.carry] = true
                    }
                    else {
                        processorState.p[.carry] = false
                    }
                    sum = sum.bcdAsHexValue
                }

    //            if processorState.p[.decimal] {
    //                if sum.lowByte & 0x0f > 0x09 {
    //                    sum += 0x06
    //                }
    //                if sum & 0xf0 > 0x90 {
    //                    sum += 0x60
    //                    // Set carry?
    //                }
    //                // TODO: Add some ticks
    //            }
                
                if isDecimal {
                    updateProcessorStatus(calculatedValue: sum, memoryValue: valueInMemory.lowByte, flags: Self.noz)
                } else {
                    updateProcessorStatus(calculatedValue: sum, memoryValue: valueInMemory.lowByte, flags: Self.nozc)
                }
                
                processorState.a = sum.lowByte
            }

        // SEC - Set Carry Flag
        case .sec:
            processorState.p[.carry] = true

        // SED - Set Decimal Mode Flag
        case .sed:
            processorState.p[.decimal] = true

        // SEI - Set Interrupt Disable Flag
        case .sei:
            processorState.p[.interruptDisable] = true

        case .skb:
            // Undocumented instruction: This doesn't do anything… think it performs a memory load or something but who cares for now
            break

        case .slo:
            // "Equivalent to ASL value then ORA value, except supporting more addressing modes. LDA #0 followed by SLO is an efficient way to shift a variable while also loading it in A."
            illegalInstructionHelper(.asl, .ora)

        case .sre:
            // "Equivalent to LSR value then EOR value, except supporting more addressing modes. LDA #0 followed by SRE is an efficient way to shift a variable while also loading it in A."
            illegalInstructionHelper(.lsr, .eor)

        // STA - Store Accumulator to Memory
        case .sta:
            write(processorState.a, to: address!)

        // STX - Store Index Register X to Memory
        case .stx:
            write(processorState.x, to: address!)

        // STY - Store Index Register Y to Memory
        case .sty:
            write(processorState.y, to: address!)
            
        // TAX - Transfer Accumulator to Index Register X
        case .tax:
            let result = processorState.a
            processorState.x = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)

        // TAY - Transfer Accumulator to Index Register Y
        case .tay:
            let result = processorState.a
            processorState.y = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)

        // TSX - Transfer Stack Pointer to Index Register X
        case .tsx:
            processorState.x = processorState.s
            updateProcessorStatus(calculatedValue: UInt16(processorState.s), flags: Self.nz)

        // TXA - Transfer Index Register X to Accumulator
        case .txa:
            let result = processorState.x
            processorState.a = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)

        // TXS - Transfer Index Register X to Stack Pointer
        case .txs:
            processorState.s = processorState.x

        // TYA - Transfer Index Register Y to Accumulator
        case .tya:
            let result = processorState.y
            processorState.a = result
            updateProcessorStatus(calculatedValue: UInt16(result), flags: Self.nz)
        }
    }
}

// Helpers
private extension CPU6502 {
    
    func stackAddressFor(lowByte: UInt8) -> UInt16 {
        UInt16(highByte: 0x01, lowByte: lowByte)
    }

    func updateProcessorStatus(calculatedValue value: UInt16,
                               memoryValue: UInt8? = nil,
                               flags: [ProcessorState.ProcessorStatusRegister.Bit]) {
        if flags.contains(.negative) {
            processorState.p[.negative] = calculateNegative(for: value)
        }
        if flags.contains(.overflow) {
            processorState.p[.overflow] = calculateOverflow(value: value, a: processorState.a, memory: memoryValue!)
        }
        if flags.contains(.zero) {
            processorState.p[.zero] = calculateZero(for: value)
        }
        if flags.contains(.carry) {
            processorState.p[.carry] = calculateCarry(for: value)
        }
    }
    
    // TODO: Document these; consider renaming "value" to "result"
    
    func calculateNegative(for value: UInt16) -> Bool {
        value & 0x0080 != 0
    }
        
    func calculateOverflow(value: UInt16, a: UInt8, memory: UInt8) -> Bool {
        // TODO: WTF
        let z = UInt16(~(a ^ memory))
        return (z & (UInt16(a) ^ value) & 0x80) != 0x00
    }
    
    func calculateZero(for value: UInt16) -> Bool {
        value & 0x00ff == 0
    }
    
    func calculateCarry(for value: UInt16) -> Bool {
        value & 0xff00 != 0
    }
    
    private func write(_ value: UInt8, to address: UInt16) {
        bus!.write(value, to: address)
    }
}

private extension NESBus {
    func load8(from address: UInt16) -> UInt8 {
        read(from: address)
    }

    func load16(from address: UInt16) -> UInt16 {
        UInt16(highByte: read(from: address &+ 1), lowByte: read(from: address))
    }
}

extension Addressable {
    func load8(from address: UInt16) -> UInt8 {
        read(from: address)
    }

    func load16(from address: UInt16) -> UInt16 {
        let lowByte = read(from: address)
        let highByte = read(from: address &+ 1)
        return .init(highByte: highByte, lowByte: lowByte)
    }
}
