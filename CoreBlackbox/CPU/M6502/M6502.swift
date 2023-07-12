//
//  M6502.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/29/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

public final class M6502 {
        
    enum Pins: UInt64 {
        // Address bus pins:
        case address0  = 0b00000000000000000000000000000001
        case address1  = 0b00000000000000000000000000000010
        case address2  = 0b00000000000000000000000000000100
        case address3  = 0b00000000000000000000000000001000
        case address4  = 0b00000000000000000000000000010000
        case address5  = 0b00000000000000000000000000100000
        case address6  = 0b00000000000000000000000001000000
        case address7  = 0b00000000000000000000000010000000
        case address8  = 0b00000000000000000000000100000000
        case address9  = 0b00000000000000000000001000000000
        case address10 = 0b00000000000000000000010000000000
        case address11 = 0b00000000000000000000100000000000
        case address12 = 0b00000000000000000001000000000000
        case address13 = 0b00000000000000000010000000000000
        case address14 = 0b00000000000000000100000000000000
        case address15 = 0b00000000000000001000000000000000
        // Data bus pins:
        case data0     = 0b00000000000000010000000000000000
        case data1     = 0b00000000000000100000000000000000
        case data2     = 0b00000000000001000000000000000000
        case data3     = 0b00000000000010000000000000000000
        case data4     = 0b00000000000100000000000000000000
        case data5     = 0b00000000001000000000000000000000
        case data6     = 0b00000000010000000000000000000000
        case data7     = 0b00000000100000000000000000000000
        // Control pins:
        case rw        = 0b00000001000000000000000000000000  // Out (...) TODO
        case sync      = 0b00000010000000000000000000000000  // Out
        case irq       = 0b00000100000000000000000000000000  // In
        case nmi       = 0b00001000000000000000000000000000  // In
        case rdy       = 0b00010000000000000000000000000000  // In
        //case aec       = 0b00100000000000000000000000000000  // In; 6510 only
        case res       = 0b01000000000000000000000000000000  // request RESET
    }
        
    public unowned var bus: Bus! {
        didSet {
            dmaController.bus = bus
        }
    }
    
    public private(set) var cycleCount: UInt64 = 0
            
    var isFetchingNewInstruction: Bool {
        pins & Pins.sync.rawValue != 0
    }
        
    public var processorState: ProcessorState {
        let m = m6502
        return ProcessorState(a: m.A, x: m.X, y: m.Y, s: m.S, pc: m.PC, p: ProcessorState.ProcessorStatusRegister(integerLiteral: m.P), pendingIRQ: .none, isHalted: false, cycleCount: cycleCount)
        // TODO: The pending IRQ here is wrong. (And isHalted could be.) But do we care about those?
    }
    
    public var processorStatusRegister: UInt8 {
        get {
            m6502.P
        }
        set {
            m6502_set_p(m6502Pointer, newValue)
        }
    }
    
    private let tickingMode: TickingMode = .byCycle
    private let instructionSet = InstructionSet()
    private var m6502Pointer: UnsafeMutablePointer<m6502_t>
    private var dmaController = DMAController()
    private var logger: Logger?

    private var address: UInt16 {
        m6502_GET_ADDR(pins)
    }
        
    private var data: UInt8 {
        get {
            m6502_GET_DATA(pins)
        }
        set {
            pins = m6502_SET_DATA(m6502Pointer, pins, newValue)
        }
    }
    
    private var m6502: m6502_t {
        m6502Pointer.pointee
    }
    
    private var pins: UInt64
    
    private var isNMIHandlingNeeded: Bool {
        get {
            pins & Pins.nmi.rawValue != 0
        }
        set {
            if newValue {
                pins |= Pins.nmi.rawValue
            } else {
                pins &= ~Pins.nmi.rawValue
            }
        }
    }
    
    private var isInReadState: Bool {
        pins & Pins.rw.rawValue != 0
    }
    
    public init(isBCDEnabled: Bool = true, logger: Logger?) {
        
        self.logger = logger
        
        // Create the m6502 (the C type that implements the actual 6502 behavior)
        let m6502DescPointer = UnsafeMutablePointer<m6502_desc_t>.allocate(capacity: 1)
        defer { m6502DescPointer.deallocate() }
        
        let m6502Pointer = UnsafeMutablePointer<m6502_t>.allocate(capacity: 1)        
        m6502DescPointer.pointee = m6502_desc_t(bcd_disabled: !isBCDEnabled, m6510_in_cb: nil, m6510_out_cb: nil, m6510_user_data: nil, m6510_io_pullup: 0, m6510_io_floating: 0)
        
        pins = m6502_init(m6502Pointer, m6502DescPointer)
        
        self.m6502Pointer = m6502Pointer
    }
    
    public func tick() {
        switch tickingMode {
        case .byCycle:
            tickByCycle()
        case .byInstruction:
            fatalError("`TickingMode.byInstruction` not currently supported in M6502")
        }
        
        // If it was needing to be handled, it started to be during this cycle, so we can clear this
        isNMIHandlingNeeded = false
    }
    
    public func setUpDMATransferToPPU(forPage page: UInt8) {
        dmaController.setUpDMATransferToPPU(forPage: page)
    }
        
    private func read() {
        data = bus.read(from: address)
    }
        
    private func write() {
        bus.write(data, to: address)
    }
    
    private func tickByCycle() {
        defer { cycleCount += 1 }
        if dmaController.isOperationInProgress {
            dmaController.tick(cyclesCompleted: cycleCount)
        } else {
            performCPUWorkForCycle()
        }
    }
    
    private func performCPUWorkForCycle() {
        // Tick the CPU
        pins = m6502_tick(m6502Pointer, pins)

        // Every cycle is either a read or a write on the 6502
        if isInReadState {
            read()
            
            // Fetching a new instruction, so let's log it
            if isFetchingNewInstruction {
                let opcode = bus.read(from: m6502.PC)
                let instruction = instructionSet.instructionForOpcode[opcode]
                logInfoPublicly(CPULog.instruction(instruction!).string)
                logInfoPublicly(CPULog.cpuState(processorState).string)
            }
        } else {
            write()
        }
    }

    private func logInfoPublicly(_ string: String) {
        // TODO: Commented out for speed
        //logger?.info("\(string, privacy: .public)")
    }
}

extension M6502: CPU {
    
    public func isInAnInfiniteLoop() -> Bool {
        
        func load16(from address: UInt16) -> UInt16 {
            UInt16(highByte: bus!.read(from: address &+ 1), lowByte: bus!.read(from: address))
        }
        
        guard isFetchingNewInstruction else { return false }
        
        let opcode = bus!.read(from: m6502.PC)
        let instruction = instructionSet.instructionForOpcode[opcode]
        
        if instruction?.mnemonic == .brk || (instruction?.mnemonic == .jmp && instruction?.addressingMode == .absolute) {
            // TODO: We should optimally support more than just .absolute…
            let nextAddress = load16(from: m6502.PC &+ 1)
            if nextAddress == m6502.PC {
                return true
            }
            // TODO: Understand - we're accidentally checking BRKs for Next Address being current PC. Didn't really mean to… but apparently that works
        }

        return false
    }
    
    public func decodeInstruction() throws -> Instruction {
        
        enum Error: Swift.Error {
            case noBus       // TODO: These shouldn't be here; maybe harmonize this function with the similar one on CPU6502.
            case invalidOpcode(UInt8)
        }
        
        guard let bus else { throw Error.noBus }
        
        let instructionSet = InstructionSet()
        let nextOpcode = bus.read(from: processorState.pc)
        guard let instruction = instructionSet.instructionForOpcode[nextOpcode] else {
            throw Error.invalidOpcode(nextOpcode)
        }
        return instruction
    }
}

extension M6502: InterruptRaiser {
    public func raiseInterrupt(_ interrupt: Interrupt) {
        switch interrupt {
        case .nmi:
            isNMIHandlingNeeded = true
        case .irq:
            fatalError("Non-NMI interrupts not yet implemented on M6502")
        }
    }
}
