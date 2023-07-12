//
//  PreviewSampleData.swift
//  Blackbox
//
//  Created by Grady Haynes on 1/4/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import CoreBlackbox

#if canImport(UIKit)
extension MainView_Previews {
    static var videoDisplayViewModel = {
        guard let screenshot = UIImage(named: "sample screenshot")?.cgImage else {
            fatalError("Preview Assests misconfigured")
        }
        return VideoDisplayViewModel(image: screenshot)
    }()

    static var accessoriesViewModel = {
        // TODO: Is there a better way to get CGImages from Preview Content without using UIImage?
        guard let patternTable0 = UIImage(named: "PatternTable0")?.cgImage,
              let patternTable1 = UIImage(named: "PatternTable1")?.cgImage
        else {
            fatalError("Preview Assests misconfigured")
        }

        var accessoriesViewModel = AccessoriesViewModel()
        accessoriesViewModel.patternTables = (patternTable0, patternTable1)
        accessoriesViewModel.systemPalette = SystemPalette.systemPaletteSampleData
        accessoriesViewModel.cpuState.p = 0x96 // just looks nice
        return accessoriesViewModel
    }()
}
#elseif canImport(AppKit)
extension MainView_Previews {
    static var videoDisplayViewModel = {
        guard let screenshot = NSImage(named: "sample screenshot")?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Preview Assests misconfigured")
        }
        return VideoDisplayViewModel(image: screenshot)
    }()

    static var accessoriesViewModel = {
        // TODO: Is there a better way to get CGImages from Preview Content without using NSImage?
        guard let patternTable0 = NSImage(named: "PatternTable0")?.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let patternTable1 = NSImage(named: "PatternTable1")?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            fatalError("Preview Assests misconfigured")
        }

        var accessoriesViewModel = AccessoriesViewModel()
        accessoriesViewModel.patternTables = (patternTable0, patternTable1)
        accessoriesViewModel.systemPalette = SystemPalette.systemPaletteSampleData
        accessoriesViewModel.cpuState.p = 0x96 // just looks nice
        return accessoriesViewModel
    }()
}
#endif

extension SystemPalette {
        
    // Values captured while running Super Mario Bros.
    
    static var systemPaletteSampleData = {
        Self(background: 34, palettes: paletteSampleData)
    }()
    
    static var paletteSampleData: NESPalettes = (
        NESPalette(41, 26, 15),
        NESPalette(54, 23, 15),
        NESPalette(48, 33, 15),
        NESPalette(39, 23, 15),
        NESPalette(22, 39, 24),
        NESPalette(26, 48, 39),
        NESPalette(22, 48, 39),
        NESPalette(15, 54, 23)
    )
}
