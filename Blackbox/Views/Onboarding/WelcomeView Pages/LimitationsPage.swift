//
//  LimitationsPage.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/21/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct LimitationsPage: View {
    var body: some View {
        VStack {
            TitledContent(title: "Only single player is available", symbolName: "figure.wave.circle") {
                Text("Game controllers and keyboards control “player one.” Support for multiple players is not yet available.")
            }
            
            Divider().hidden()
            Divider().hidden()
            Divider().hidden()
            
            TitledContent(title: "Sound is not yet supported", symbolName: "speaker.slash") {
                Text("Sound may be available in a future release of Blackbox.")
            }
        }
    }
}
