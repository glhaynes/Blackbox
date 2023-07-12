//
//  SystemPaletteView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/15/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

struct SystemPaletteView: View {

    let systemPalette: SystemPalette
    
    var body: some View {
        Grid {
            // Background palettes
            GridRow {
                SinglePaletteView(palette: systemPalette.palettes.0, backgroundColor: systemPalette.background)
                SinglePaletteView(palette: systemPalette.palettes.1, backgroundColor: systemPalette.background)
                SinglePaletteView(palette: systemPalette.palettes.2, backgroundColor: systemPalette.background)
                SinglePaletteView(palette: systemPalette.palettes.3, backgroundColor: systemPalette.background)
            }
            
            // Sprite palettes
            GridRow {
                SinglePaletteView(palette: systemPalette.palettes.4, backgroundColor: nil)
                SinglePaletteView(palette: systemPalette.palettes.5, backgroundColor: nil)
                SinglePaletteView(palette: systemPalette.palettes.6, backgroundColor: nil)
                SinglePaletteView(palette: systemPalette.palettes.7, backgroundColor: nil)
            }
        }
    }
}

struct SystemPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        SystemPaletteView(systemPalette: SystemPalette.systemPaletteSampleData)
    }
}
