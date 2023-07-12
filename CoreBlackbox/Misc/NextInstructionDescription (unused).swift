//
//  NextInstructionDescription (unused).swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/26/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

func nextInstructionDescription(memoryInterface: some MemoryInterface, instruction: Instruction, baseAddress: UInt16?, effectiveAddress address: UInt16?) -> String {
    
    let addressString8 = address == nil ? "" : String(format: "$%02X", address!)
    let addressString16 = address == nil ? "" : String(format: "$%04X", address!)
    let memoryTarget = address == nil ? "" : String(format: "$%02X", memoryInterface.load16(from: address!))     // TODO: This is where we're losing our keyboard in EhBASIC if we include the call to this function
    
    // So the 2 bytes at the operand address...
    let baseAddressContents8 = baseAddress == nil ? 0 : memoryInterface.load8(from: baseAddress!)
    let baseAddressContents16 = baseAddress == nil ? 0 : memoryInterface.load16(from: baseAddress!)
    let baseAddressContentsString8 = baseAddress == nil ? "" : String(format: "$%02X", baseAddressContents8)
    let baseAddressContentsString16 = baseAddress == nil ? "" : String(format: "$%04X", baseAddressContents16)
    
    let result: String?
    switch instruction.addressingMode {
    case .implied:
        result = nil
    case .accumulator:
        result = nil
    case .immediate:
        result = "#\(memoryTarget)"
    case .stack:
        result = "\(addressString16) (contents: \(memoryTarget))"
    case .programCounterRelative:
        result = "\(addressString16) (contents: \(memoryTarget))"
    case .zeroPage:
        result = "\(addressString8) (contents: \(memoryTarget))"
    case .zeroPageIndexedWithX:
        result = "\(baseAddressContentsString8),X so \(addressString8) (contents: \(memoryTarget))"
    case .zeroPageIndexedWithY:
        result = "\(baseAddressContentsString8),Y so \(addressString8) (contents: \(memoryTarget))"
    case .zeroPageIndexedIndirectWithX:
        result = "\(addressString16),(X) (contents: \(memoryTarget))"  // TODO
    case .zeroPageIndirectIndexedWithY:
        result = "(\(addressString16)),Y (contents: \(memoryTarget))"  // TODO
    case .absolute:
        result = "\(addressString16) (contents: \(memoryTarget))"
    case .absoluteIndexedWithX:
        result = "\(baseAddressContentsString16),X so \(addressString16) (contents: \(memoryTarget))"
    case .absoluteIndexedWithY:
        result = "\(baseAddressContentsString16),Y so \(addressString16) (contents: \(memoryTarget))"
    case .absoluteIndirect:
        let absolute = baseAddressContents16
        let indirect = String(format: "$%04X", memoryInterface.load16(from: absolute))
        result = "(\(absolute.hexString)) (contents: \(indirect))" // TODO
    }
    
    return [
        instruction.mnemonic.rawValue.uppercased(),
        result,
        "[\(instruction.addressingMode)]"
    ]
    .compactMap { $0 }
    .joined(separator: " ")
}

private extension MemoryInterface {

    func load8(from address: UInt16) -> UInt8 {
        self[address]
    }

    func load16(from address: UInt16) -> UInt16 {
        UInt16(highByte: self[address &+ 1], lowByte: self[address])
    }
}
