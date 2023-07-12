//
//  OnscreenControllerWithHandling.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/1/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

#if os(iOS)

import SwiftUI
import OnscreenController
import Controllers

struct OnscreenControllerWithHandling: View {
    
    /// The function we call whenever there’s a change in which buttons are pressed.
    @Environment(\.onscreenButtonsPressed) private var onscreenButtonsPressed
    
    /// The buttons that are currently being pressed on the Onscreen Controller.
    @State private var pressedButtons: Set<NESButton> = []
    
    var body: some View {
        OnscreenController(
            up: { set(.up, $0) },
            down: { set(.down, $0) },
            left: { set(.left, $0) },
            right: { set(.right, $0) },
            select: { set(.select, $0) },
            start: { set(.start, $0) },
            b: { set(.b, $0) },
            a: { set(.a, $0) }
        )
        .onChange(of: pressedButtons) { onscreenButtonsPressed($0) }
    }
    
    private func set(_ button: NESButton, _ isOn: Bool) {
        if isOn {
            pressedButtons.insert(button)
        } else {
            pressedButtons.remove(button)
        }
    }
}

#endif
