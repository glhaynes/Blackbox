//
//  OnscreenControllerPage.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/21/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct OnscreenControllerPage: View {
    var body: some View {
        TitledContent(title: "Play using onscreen controls", symbolName: "dpad") {
            Text("""
                If you don’t have a game controller or keyboard, you can use the onscreen controller to play.
                
                The onscreen controller will be shown automatically when no game controllers or keyboards are connected.
                """)
        }
    }
}
