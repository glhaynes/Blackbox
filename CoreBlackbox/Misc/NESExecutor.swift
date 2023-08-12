//
//  NESExecutor.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/2/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum NESExecutor {
    public static func run(_ bus: some Bus,
                           inBatchesOfSystemCycleCount cycleBatchCount: UInt64,
                           stoppingAfterBatchIf shouldStopAfterBatch: ((any Bus) -> Bool) = { _ in false }) {
        var stop = false
        while(!stop) {
            var cyclesThisRun: UInt64 = 0
            while cyclesThisRun < cycleBatchCount {
                bus.tick()
                cyclesThisRun += 1
            }
            
            stop = shouldStopAfterBatch(bus)
        }
    }
}
