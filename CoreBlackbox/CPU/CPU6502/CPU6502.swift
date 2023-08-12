//
//  CPU6502.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 4/15/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

public final class CPU6502 {
    
    // These have to be `internal` because the implementations are in a different file
    public var processorState: ProcessorState
    public weak var bus: (any Bus)? {
        didSet {
            dmaController.bus = bus
        }
    }

    let isRespectingDecimalMode: Bool
    
    private let instructionDecoder: InstructionDecoder
    private var dmaController = DMAController()
    private var logger: Logger?
    private var cyclesRemainingForCurrentInstruction = 0

    public init(
        bus: NESBus?,
        instructionDecoder: InstructionDecoder,
        processorState: ProcessorState? = nil,
        isRespectingDecimalMode: Bool = true,
        logger: Logger? = nil
    ) {
        self.bus = bus
        self.instructionDecoder = instructionDecoder
        self.processorState = processorState ?? ProcessorState(a: 0, x: 0, y: 0, s: 0xfd, pc: 0xfffc, p: 0, pendingIRQ: .reset, isHalted: false, cycleCount: 0)
        self.isRespectingDecimalMode = isRespectingDecimalMode
        self.logger = logger
    }
        
    private func runNextInstruction() {
        assert(cyclesRemainingForCurrentInstruction == 0)
        
        logInfoPublicly(CPULog.cpuState(processorState).string)

        if processorState.pendingIRQ != .none {
            handlePendingIRQ()
            // FIXME: We need to make this take multiple cycles (how many?)
            return
        } else {
            let nextInstruction = try! InstructionDecoder.decodeInstruction(bus: bus!, pc: processorState.pc)
            logInfoPublicly(CPULog.instruction(nextInstruction).string)
            cyclesRemainingForCurrentInstruction += nextInstruction.cycleCount
            
            let nextOperandAddress = processorState.pc &+ 1
            let newPC = processorState.pc &+ UInt16(nextInstruction.size)
            processorState.pc = newPC
            execute(nextInstruction, operandAddress: nextOperandAddress)
        }
    }
        
    private func handlePendingIRQ() {
        switch (processorState.pendingIRQ, processorState.p[.interruptDisable]) {
        case (.none, _):
            break
        case (.regular, true):
            // Masked interrupt
            logInfoPublicly(CPULog.interrupt(.maskable(isMasked: true)).string)
            processorState.pendingIRQ = .none
        case (.regular, false):
            logInfoPublicly(CPULog.interrupt(.maskable(isMasked: false)).string)
            handleInterrupt(isNonMaskable: false)
            processorState.pendingIRQ = .none
        case (.nonMaskable, _):
            logInfoPublicly(CPULog.interrupt(.nonMaskable).string)
            handleInterrupt(isNonMaskable: true)
            processorState.pendingIRQ = .none
        case (.reset, _):
            logInfoPublicly(CPULog.reset.string)
            reset()
        }
    }
    
    private func execute(_ instruction: Instruction, operandAddress: UInt16) {
        
        let (parameterAddress, cyclesSpentAccessingMemory) =
            calculateInstructionTarget(operandAddress: operandAddress,
                                       addressingMode: instruction.addressingMode)
        
        // FIXME: Are we happy with this?
        cyclesRemainingForCurrentInstruction += cyclesSpentAccessingMemory
        
        execute(mnemonic: instruction.mnemonic,
                addressingMode: instruction.addressingMode,
                parameterAddress: parameterAddress)
        
        // To be cycle-ticked, we'd need a state machine that handles the execution unit's duties and is progressed by a `Clock` instead of this
        processorState.cycleCount += UInt64(cyclesSpentAccessingMemory) + UInt64(instruction.cycleCount)
        
        return
    }
        
    private func handleInterrupt(isNonMaskable: Bool) {

        //logger?.log(.interrupt(isNonMaskable: isNonMaskable))
        //logger?.log(.other, "Interrupt - isNonMaskable: \(isNonMaskable)", processorState.cycleCount)
        
        let stackAddress = stackAddressFor(lowByte: processorState.s)
        let returnToPC = processorState.pc  // Address the interrupt handler should return to
        
        write(returnToPC.highByte, to: stackAddress)
        write(returnToPC.lowByte, to: stackAddress &- 1)
        write(processorState.p.value, to: stackAddress &- 2)
        processorState.s = processorState.s &- 3
        processorState.pc = bus!.load16(from: isNonMaskable ? 0xfffa : 0xfffe)
        if !isNonMaskable {
            processorState.p[.interruptDisable] = true
            processorState.p[.break] = false
        }
    }
    
    private func write(_ value: UInt8, to address: UInt16) {
        bus!.write(value, to: address)
    }
    
    private func reset() {
        processorState.pc = bus!.load16(from: 0xfffc)
        processorState.pendingIRQ = .none
    }
    
    private func calculateInstructionTarget(
        operandAddress: UInt16,
        addressingMode: Instruction.AddressingMode
    ) -> (parameterAddress: UInt16?, cyclesSpentAccessingMemory: Int) {
        
        var cyclesSpent = 0
        let address: UInt16?
        
        switch addressingMode {
        
        case .zeroPage:
            // Use the byte after the opcode as the low byte
            address = UInt16(lowByte: bus!.load8(from: operandAddress))
        
        case .programCounterRelative:
            // Treat the byte after the opcode as a signed offset from the Program Counter
            // TODO: Revise this some
            let relativeAddress = Int8(bitPattern: bus!.load8(from: operandAddress))
            
            // I tried this, but it caused the branching test to fail...
            //let newAddress32 = Int32(processorState.pc) + (Int32(relativeAddress) - Int32(relativeAddress) < 0x80 ? 0 : 256)
            let newAddress32 = Int32(processorState.pc) + (Int32(relativeAddress) - (Int32(relativeAddress) < 0x80 ? 0 : 256))
            // Need to: Subtract either 0 or 256 from the relativeAddress (depending on if its high bit is set)
            // Or can we just &+?!
            address = UInt16(truncatingIfNeeded: newAddress32)
            //address = relativeAddress + pc - (relativeAddress < 0x80 ? 0 : 256)  // TODO: Why?
        
        case .implied:
            address = nil
        
        case .absolute:
            address = bus!.load16(from: operandAddress)
        
        case .accumulator:
            let addressInA = UInt16(lowByte: processorState.a)
            address = bus!.load16(from: addressInA)
        
        case .immediate:
            address = operandAddress
        
        case .zeroPageIndexedWithX:
            address = UInt16(lowByte: UInt16(bus!.load8(from: operandAddress) &+ processorState.x).lowByte)
        
        case .zeroPageIndexedWithY:
            address = UInt16(lowByte: UInt16(bus!.load8(from: operandAddress) &+ processorState.y).lowByte)
        
        case .absoluteIndexedWithX:
            var addr = bus!.load16(from: operandAddress)
            let x16 = UInt16(processorState.x)
            if (addr & 0xff00) != ((addr &+ x16) & 0xff00) {
                // Extra cycle if crossing page boundaries
                cyclesSpent = 1
            }
            addr &+= x16
            address = addr
        
        case .absoluteIndexedWithY:
            var addr = bus!.load16(from: operandAddress)
            let y16 = UInt16(processorState.y)
            if (addr & 0xff00) != ((addr &+ y16) & 0xff00) {
                // Extra cycle if crossing page boundaries
                cyclesSpent = 1
            }
            addr &+= y16
            address = addr
        
        case .zeroPageIndexedIndirectWithX:
            // Pre-indexed Indirect mode. Find the 16-bit address starting at the given location plus the current X register. The value is the contents of that address.
            let zeroPageAddress = UInt16(lowByte: bus!.load8(from: operandAddress))
            let plusIndexAdded = (zeroPageAddress &+ UInt16(lowByte: processorState.x)).lowByte
            if plusIndexAdded == 0xff {
                // Handle wraparound of zero-page
                let lowByte = bus!.load8(from: 0xff)
                let highByte = bus!.load8(from: 0x00)
                address = UInt16(highByte: highByte, lowByte: lowByte)
            } else {
                address = bus!.load16(from: UInt16(lowByte: plusIndexAdded))
            }
        
        case .zeroPageIndirectIndexedWithY:
            let zeroPageAddress = UInt16(lowByte: bus!.load8(from: operandAddress))
            let target: UInt16
            if zeroPageAddress == 0xff {
                // Handle wraparound of zero-page
                let lowByte = bus!.load8(from: 0xff)
                let highByte = bus!.load8(from: 0x00)
                target = UInt16(highByte: highByte, lowByte: lowByte)
            } else {
                target = bus!.load16(from: zeroPageAddress)
            }

            address = target &+ UInt16(lowByte: processorState.y)
        
        case .absoluteIndirect:
            let startingAddress = bus!.load16(from: operandAddress)
            let is6502IndirectJMPBugTriggered = startingAddress.lowByte == 0xff
            if is6502IndirectJMPBugTriggered {
                let lowByte = bus!.load8(from: startingAddress)
                let highByteTarget = UInt16(highByte: startingAddress.highByte, lowByte: 0)
                let highByte = bus!.load8(from: highByteTarget)
                address = UInt16(highByte: highByte, lowByte: lowByte)
            } else {
                address = bus!.load16(from: startingAddress)
            }
            
        case .stack:
            address = nil
            fatalError()  // TODO: ?? ... Need to go back and mark some of the .implied ones .stack, I think...
        }
        
        return (address, cyclesSpent)
    }
    
    // CLEANUP: Arrange flags in order in calls and in func (NVZC, probably)
    
    private func stackAddressFor(lowByte: UInt8) -> UInt16 {
        UInt16(highByte: 0x01, lowByte: lowByte)
    }
    
    private func logInfoPublicly(_ string: String) {
        // TODO: Commented out for speed
        //logger?.info("\(string, privacy: .public)")
    }
}

extension CPU6502: CPU {
    
    public var cycleCount: UInt64 {
        processorState.cycleCount
    }
    
    public func isInAnInfiniteLoop() -> Bool {
        
        func load16(from address: UInt16) -> UInt16 {
            UInt16(highByte: bus!.read(from: address &+ 1), lowByte: bus!.read(from: address))
        }
        
        let nextInstruction = try! InstructionDecoder.decodeInstruction(bus: bus!, pc: processorState.pc)
        let pc = processorState.pc
        return (nextInstruction.mnemonic == .brk && load16(from: pc + 1) == pc) ||
               (nextInstruction.mnemonic == .jmp && nextInstruction.addressingMode == .absolute && load16(from: pc + 1) == pc)
    }

    public func setUpDMATransferToPPU(forPage page: UInt8) {
        dmaController.setUpDMATransferToPPU(forPage: page)
    }
    
    public func tick() {
        if dmaController.isOperationInProgress {
            dmaController.tick(cyclesCompleted: cycleCount)
            processorState.cycleCount += 1
        } else {
            guard cyclesRemainingForCurrentInstruction == 0 else {
                cyclesRemainingForCurrentInstruction -= 1
                return
            }
            runNextInstruction()
        }
    }
}

extension CPU6502: InterruptRaiser {
    public func raiseInterrupt(_ interrupt: Interrupt) {
        switch interrupt {
        case .irq:
            processorState.pendingIRQ = .regular
        case .nmi:
            processorState.pendingIRQ = .nonMaskable
        }
    }
}
