//
//  NESExecutor.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/2/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum NESExecutor {
    
    private static var totalSystemCycles: UInt64 = 0
    public static func run(_ bus: some Bus,
                           inBatchesOfSystemCycleCount cycleBatchCount: UInt64,
                           stoppingAfterBatchIf stopIf: ((any Bus) -> Bool) = { _ in false }) {
        var stop = false
        while(!stop) {
            var cyclesThisRun: UInt64 = 0
            while cyclesThisRun < cycleBatchCount /* * 3 */ {
                bus.tick()
                cyclesThisRun += 1
                totalSystemCycles += 1
            }
            
            stop = stopIf(bus) // Pass it the bus to inspect
        }
    }
    
    // Nothing uses this as of this writing
    public static func run(_ bus: NESBus, forMaximumCycleCountOf maxCycleCount: UInt64) {
        var cyclesThisRun: UInt64 = 0
        while cyclesThisRun <= maxCycleCount {
            bus.tick()
            cyclesThisRun += 1
        }
    }
}
