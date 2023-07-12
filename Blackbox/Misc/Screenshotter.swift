//
//  Screenshotter.swift
//  Blackbox
//
//  Created by Grady Haynes on 10/10/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreBlackbox

enum Screenshotter {
    
    static func screenshot(bus: NESBus) -> CGImage? {
        guard let frame = bus.ppu.lastFrame else { return nil }
        let size = CGSize(width: 256, height: 234/*224*/)
        var croppedBytes: [[RGBValue]] = []
        for y in 0..<Int(size.height) {
            let rowStart = y * 341
            croppedBytes.append(Array(frame[rowStart...rowStart + 255]))
        }
        return cgImage(size: size, rgbValues: croppedBytes)
    }
    
    static func patternTableImages(bus: NESBus) -> (CGImage, CGImage)? {
        let patternTables = bus.ppu.rawPatternTables(palette: 0)
        return (
            cgImage(size: .init(width: 128, height: 128), rgbValues: patternTables.one.rgbValues),
            cgImage(size: .init(width: 128, height: 128), rgbValues: patternTables.two.rgbValues)
        )
    }
    
    private static func cgImage(size: CGSize, rgbValues: [[RGBValue]]) -> CGImage {
        let colorPlusAlphaBytes: [UInt8] = rgbValues.flatMap { $0.flatMap { [$0.red, $0.green, $0.blue, 255] } }
        let provider = CGDataProvider(data: Data(colorPlusAlphaBytes) as CFData)!
        return CGImage(width: Int(size.width),
                       height: Int(size.height),
                       bitsPerComponent: 8,
                       bitsPerPixel: 32,
                       bytesPerRow: Int(size.width) * 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)!
    }
}
