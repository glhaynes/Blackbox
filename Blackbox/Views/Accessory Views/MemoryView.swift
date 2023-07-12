//
//  MemoryView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/12/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI

struct MemoryView: View {
    
    private static let colorMappings = (0...255).map { _ in
        Color(red: .random(in: (0..<1)),
              green: .random(in: (0..<1)),
              blue: .random(in: (0..<1)))
    }

    @Binding var memory: [UInt8]
    var rowWidth: Int
    var isUsingRandomColors = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<rowCount(width: rowWidth), id: \.self) { rowIndex in
                let bytes = memory(rowIndex: rowIndex, rowWidth: rowWidth)
                rowView(forBytes: bytes)
            }
        }
    }

    private func rowView(forBytes bytes: [UInt8]) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<bytes.count, id: \.self) { offset in
                let byte = bytes[offset]
                Text("\(byte.hexStringWithNoLeading0X)")
                    .foregroundColor(isUsingRandomColors ? Self.colorMappings[Int(byte)] : .primary)
            }
        }
        .monospaced()
    }

    private func memory(rowIndex: Int, rowWidth: Int) -> [UInt8] {
        assert(rowIndex >= 0 && rowWidth > 0)
        let start = rowWidth * rowIndex
        let end = min(start + rowWidth, memory.count)
        return Array(memory[start..<end])
    }
    
    private func rowCount(width: Int) -> Int {
        (memory.count / width) + (memory.count % width == 0 ? 0 : 1)
    }
}

struct MemoryView_Previews: PreviewProvider {
    private static func randomBytes(count: Int) -> [UInt8] {
        assert(count != .max)
        return (0..<count).map { _ in UInt8.random(in: (0...255)) }
    }
    
    static var previews: some View {
        let randomBytes256 = randomBytes(count: 256)
        VStack {
            MemoryView(memory: .constant(randomBytes256), rowWidth: 16, isUsingRandomColors: false)
                .previewLayout(.sizeThatFits)
            Spacer()
            MemoryView(memory: .constant(randomBytes256), rowWidth: 16, isUsingRandomColors: true)
                .previewLayout(.sizeThatFits)
        }
    }
}
