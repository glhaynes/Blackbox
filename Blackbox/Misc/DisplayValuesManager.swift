//
//  DisplayValuesManager.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/20/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
import CoreGraphics
import Combine

/// Handles video refresh and publishes `VideoDisplayViewModel` and `AccessoriesViewModel`. Also records and prints some basic performance metrics if environment variable `PERFORMANCE_METRICS` is set.
final class DisplayValuesManager {
    
    private let videoDisplayViewModel: VideoDisplayViewModel
    private let accessoriesViewModel: AccessoriesViewModel
    private let emulatorModel: EmulatorModel
    private let logger: Logger?
    private let videoRefresher: VideoRefresher

    #if PERFORMANCE_METRICS
    var hasAROMBeenLoaded = false
    private var frameStartEnd: [(Date, Date)] = []
    #endif
    
    init(videoDisplayViewModel: VideoDisplayViewModel,
         accessoriesViewModel: AccessoriesViewModel,
         emulatorModel: EmulatorModel, 
         logger: Logger?)
    {
        self.videoDisplayViewModel = videoDisplayViewModel
        self.accessoriesViewModel = accessoriesViewModel
        self.emulatorModel = emulatorModel
        self.logger = logger
        
        self.videoRefresher = VideoRefresher()
    }
    
    func startVideoRefresh() {
        videoRefresher.startVideoRefresh { [unowned self] in
            self.handleFrame()
        }
    }
            
    private func handleFrame() {
        #if PERFORMANCE_METRICS
        let outputAtFrameCount = 1000
        let frameStart = Date()
        #endif
        
        updateFrameAndContinueEmulating()
        
        #if PERFORMANCE_METRICS
        if hasAROMBeenLoaded {
            let frameEnd = Date()
            frameStartEnd.append((frameStart, frameEnd))
            if frameStartEnd.count == outputAtFrameCount, let logger = logger {
                PerformanceMetricsHandler.logPerformanceMetrics(for: frameStartEnd, logger: logger)
            }
        }
        #endif
    }
    
    private func updateFrameAndContinueEmulating() {
        do {
            try emulatorModel.runUntilNewDisplayValuesAvailable()
        } catch {
            return
        }
        
        videoDisplayViewModel.image = emulatorModel.screenshot

        accessoriesViewModel.cpuState = emulatorModel.cpuState
        accessoriesViewModel.cpuCycleCount = emulatorModel.cpuCycleCount
        accessoriesViewModel.patternTables = emulatorModel.patternTables
        accessoriesViewModel.systemPalette = emulatorModel.systemPalette

        emulatorModel.displayValuesHaveBeenConsumed()
    }
}

#if PERFORMANCE_METRICS
private struct PerformanceMetricsHandler {
    static func logPerformanceMetrics(for frameStartEnd: [(Date, Date)], logger: Logger) {
        let timeIntervalsBetweenFrames = (0..<frameStartEnd.count - 1).map { i in
            frameStartEnd[i + 1].0.timeIntervalSince(frameStartEnd[i].0)
        }
        
        let averageTimeIntervalBetweenFrames = timeIntervalsBetweenFrames.reduce(0.0, +) / Double(frameStartEnd.count - 1)
        
        let averageFrameRenderingTime = frameStartEnd.reduce(into: 0.0) { sum, frameStartEnd in
            sum += frameStartEnd.1.timeIntervalSince(frameStartEnd.0)
        } / Double(frameStartEnd.count)
        
        let averagePercentageOfTimeIntervalBetweenFramesTakenUpByRendering = (averageFrameRenderingTime / averageTimeIntervalBetweenFrames) * 100.0
        
        let fps = 1.0 / averageTimeIntervalBetweenFrames
        
        logger.log(level: .info, "averageTimeIntervalBetweenFrames: \(averageTimeIntervalBetweenFrames) = \(fps) fps")
        logger.log(level: .info, "averageFrameRenderingTime: \(averageFrameRenderingTime) -> frame rendering takes up \(averagePercentageOfTimeIntervalBetweenFramesTakenUpByRendering.rounded())%")
        logger.log(level: .info, "shortest: \(timeIntervalsBetweenFrames.min()!), longest: \(timeIntervalsBetweenFrames.max()!)")
    }
}
#endif
