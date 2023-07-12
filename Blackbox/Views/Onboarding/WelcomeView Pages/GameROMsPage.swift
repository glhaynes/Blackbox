//
//  GameROMsPage.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/21/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct GameROMsPage: View {
    var body: some View {
        TitledContent(title: "Playing NES Software", symbolName: "doc.viewfinder") {
            Text("""
                Software for the NES was distributed in [Game Paks](https://en.wikipedia.org/wiki/Nintendo_Entertainment_System_Game_Pak), also known as cartridges.
                
                Files containing the contents of the ROM chips in Game Paks are commonly referred to as “ROMs.” ROMs containing supported games and in “`.nes`” ([iNES](https://www.nesdev.org/wiki/INES)) format can be played in Blackbox.
                
                Supported games include many of the classic [“black box” Game Paks](https://videogamegraders.com/nes-black-box-games-details/) released during the first years the NES was sold.
                
                Support for more games may be available in a future release.
                """)
            .tint(Color.accentColor)
            .padding([.horizontal], 20)  // Little extra padding to make this easier to read
        }
    }
}
