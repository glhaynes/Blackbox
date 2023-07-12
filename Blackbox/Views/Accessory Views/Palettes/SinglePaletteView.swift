//
//  SinglePaletteView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/15/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

struct SinglePaletteView: View {

    private static let innerRadiusDivider = 2.75

    @Environment(\.colorScheme) private var colorScheme
    
    let palette: NESPalette
    let backgroundColor: NESColorIndex?

    var body: some View {

        let colorCount = 3
        let arcLength = Angle.degrees(360.0 / 3)
        let borderColor: Color = colorScheme == .dark ? .gray : .black

        GeometryReader { proxy in
            let outerRadius = min(proxy.size.width, proxy.size.height) / 2
            let innerRadius = outerRadius / Self.innerRadiusDivider
            let borderWidth = min(proxy.size.width, proxy.size.height) / 40

            ForEach(0..<colorCount, id: \.self) { colorIndex in
                
                let thisPalette: NESColorIndex = {
                    switch colorIndex {
                    case 0: return palette.0
                    case 1: return palette.1
                    case 2: return palette.2
                    default: fatalError()
                    }
                }()
                
                Wedge(radius: outerRadius, width: arcLength)
                    .foregroundColor(thisPalette.rgbValue.swiftUIColor)
                    .overlay {
                        // Clear out the middle
                        // TODO: Can we do this better??
                        Circle()
                            .frame(width: innerRadius * 2)
                            .foregroundColor(backgroundColor?.rgbValue.swiftUIColor ?? .clear)
                    }
                    .overlay {
                        // Add a border
                        Circle()
                            .strokeBorder(borderColor, lineWidth: borderWidth)
                    }
                    .rotationEffect(Angle.degrees(-30 + arcLength.degrees * Double(colorIndex)))
            }

        }
        .aspectRatio(contentMode: .fit)
    }
}

struct SinglePaletteView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LabeledContent {
                SinglePaletteView(palette: SystemPalette.systemPaletteSampleData.palettes.0, backgroundColor: nil)
            } label: {
                Text("Background palette")
            }

            LabeledContent {
                SinglePaletteView(palette:
                                    SystemPalette.systemPaletteSampleData.palettes.1, backgroundColor: SystemPalette.systemPaletteSampleData.background)
            } label: {
                Text("Foreground palette")
                Text("")
                Text("Central color is the “universal background color.”")
            }
        }
    }
}

private extension NESColorIndex {
    var rgbValue: RGBValue {
        NESRenderPalette[self]
    }
}

private extension RGBValue {
    var swiftUIColor: Color {
        .init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
