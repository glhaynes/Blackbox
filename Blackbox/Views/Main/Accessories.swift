//
//  Accessories.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/23/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

struct Accessories: View {
    
    /// A `SystemPalette` suitable for display when there is not an available system palette.
    private static let fallbackSystemPalette = {
        SystemPalette(background: 0, palettes: (
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15),
            NESPalette(15, 15, 15)
        ))
    }()

    @EnvironmentObject private var accessoriesViewModel: AccessoriesViewModel
    @Environment(\.colorScheme) private var colorScheme

    #if os(iOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #elseif os(macOS)
    private let verticalSizeClass = MacOSStubSizeClass.regular
    #endif
    
    var body: some View {
        
        VStack {
            
            // We only show the pattern tables on macOS but only because we know there's room for them on a Mac's display.
            // TODO: Show them when appropriate on other platforms.
            #if os(macOS)
            VStack(spacing: 20) {
                Text("Pattern Tables")
                    .font(.headline)
                    .lineLimit(2)
                HStack {
                    patternTableView(accessoriesViewModel.patternTables?.0, "1")
                    patternTableView(accessoriesViewModel.patternTables?.1, "2")
                }
            }
            .padding()
            #endif
            
            VStack(spacing: 20) {
                Text("Palettes").font(.headline)
                SystemPaletteView(systemPalette: systemPalette)
            }
            .padding()
            
            // CPU
            VStack(spacing: 10) {
                let cpuState = accessoriesViewModel.cpuState
                
                Text("CPU").font(.headline)
                
                let cycleCount = accessoriesViewModel.cpuCycleCount
                ZStack {
                    // Keep this column's size from expanding rapidly upon startup of emulation
                    HStack(spacing: 0) {
                        Text("Cycles: ")
                        Text("100,000,000,000").monospacedDigit()
                    }
                    .opacity(0)
                    
                    HStack(spacing: 0) {
                        Text("Cycles: ")
                        Text("\(cycleCount)").monospacedDigit()
                    }
                }
                
                ProcessorRegisterView(ps: cpuState)
                
                HStack(spacing: 0) {
                    Text("Flags: ")
                    ProcessorStatusView(psr: cpuState.p)
                }
            }
            .font(verticalSizeClass == .compact ? .caption : .body)
            .padding()
        }
        .padding(.vertical, 10)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .frame(maxHeight: .infinity)
    }
    
    private var systemPalette: SystemPalette {
        accessoriesViewModel.systemPalette ?? Self.fallbackSystemPalette
    }
    
    private func patternTableView(_ image: CGImage?, _ label: String) -> some View {
        Group {
            if let image {
                Image(image, scale: 1.0, label: Text(label))
                    .resizable()
            } else {
                Color(white: colorScheme == .dark ? 0.065 : 0.15)
            }
        }
        .aspectRatio(8.0/7, contentMode: .fit)
        .cornerRadius(4)
    }
}

struct Accessories_Previews: PreviewProvider {
    static var previews: some View {
        Accessories()
            .environmentObject(AccessoriesViewModel())
    }
}
