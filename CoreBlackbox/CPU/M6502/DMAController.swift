//
//  DMAController.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/28/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

final class DMAController {
    
    private struct Transfer {
        var address: UInt16
        var isWaitCycleNeeded = true
        var buffer: UInt8 = 0
    }
    
    public unowned var bus: Bus!
    
    var isOperationInProgress: Bool {
        transfer != nil
    }
    
    private var transfer: Transfer?
            
    init() { }
    
    func setUpDMATransferToPPU(forPage page: UInt8) {
        assert(transfer == nil)
        transfer = Transfer(address: .init(highByte: page))
    }
    
    func tick(cyclesCompleted: UInt64) {
        
        guard transfer != nil else {
            // Should never end up here - we're expecting the CPU to have checked that there's a transfer needing to be done before ticking us.
            fatalError()
        }
        
        guard !transfer!.isWaitCycleNeeded else {
            // We need to wait for the next even CPU cycle to start the DMA transfer
            if cyclesCompleted % 2 == 1 {
                transfer!.isWaitCycleNeeded = false
            }
            return
        }
            
        let isEvenCycle = cyclesCompleted % 2 == 0
        if isEvenCycle {
            // On even cycles, we read from the bus
            transfer!.buffer = bus.read(from: transfer!.address)
        } else {
            // On odd cycles, we write to PPU OAM what we read on the previous (even) cycle
            bus.dmaWriteToPPU(transfer!.buffer, oamMemoryAddress: transfer!.address.lowByte)
            
            let isDMAComplete = transfer!.address.lowByte == 0xff
            if isDMAComplete {
                transfer = nil
            } else {
                transfer!.address += 1
            }
        }
    }
}
