//
//  CPU.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/5/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public protocol CPU: InterruptRaiser, AnyObject {
    var processorState: ProcessorState { get }
    var cycleCount: UInt64 { get }
    func isInAnInfiniteLoop() -> Bool
    func setUpDMATransferToPPU(forPage page: UInt8)
    func tick()
}
