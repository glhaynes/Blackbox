//
//  GCKeyboardButtonsChannel.swift
//  Controllers
//
//  Created by Grady Haynes on 4/25/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import GameController
import AsyncAlgorithms

final class GCKeyboardButtonsChannel {
        
    let gcKeyboard: GCKeyboard
    let channel: AsyncChannel<Set<NESButton>> = .init()

    private var buttons: Set<NESButton> = []
    
    deinit {
        channel.finish()
    }
    
    @MainActor
    init(gcKeyboard: GCKeyboard) {
        self.gcKeyboard = gcKeyboard
        registerPressedChangedHandler()
    }
    
    @MainActor
    private func registerPressedChangedHandler() {
        
        let keyboardCodeToNESButton: [String: NESButton] = [
            GCKeyUpArrow: .up,
            GCKeyDownArrow: .down,
            GCKeyLeftArrow: .left,
            GCKeyRightArrow: .right,
            GCKeyTab: .select,
            GCKeyReturnOrEnter: .start,
            GCKeyA: .b,
            GCKeyS: .a
        ]
        
        for (gcKey, nesButton) in keyboardCodeToNESButton {
            gcKeyboard.keyboardInput?.buttons[gcKey]?.pressedChangedHandler = { [unowned self] button, value, isPressed in
                setButton(nesButton, isPressed: isPressed)
                sendButtons()
            }
        }
    }
    
    private func setButton(_ button: NESButton, isPressed: Bool) {
        if isPressed {
            buttons.insert(button)
        } else {
            buttons.remove(button)
        }
    }
    
    private func sendButtons() {
        let buttonsCopy = buttons
        Task { @MainActor in
            await channel.send(buttonsCopy)
        }
    }
}
