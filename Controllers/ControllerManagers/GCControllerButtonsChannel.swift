//
//  GCControllerButtonsChannel.swift
//  Controllers
//
//  Created by Grady Haynes on 4/25/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import GameController
import AsyncAlgorithms

final class GCControllerButtonsChannel {
        
    let gcController: GCController
    let channel: AsyncChannel<Set<NESButton>> = .init()

    private var buttons: Set<NESButton> = []
    
    deinit {
        channel.finish()
    }
    
    @MainActor
    init(gcController: GCController) {
        self.gcController = gcController
        registerDpadHandler()
        registerNonDpadButtonsHandlers()
    }
    
    @MainActor
    private func registerDpadHandler() {
        gcController.extendedGamepad?.dpad.valueChangedHandler = { [unowned self] dpad, xValue, yValue in
            let buttonValues: [(NESButton, Bool)] = [
                (.up, yValue == 1.0),
                (.down, yValue == -1.0),
                (.left, xValue == -1.0),
                (.right, xValue == 1.0),
            ]

            for (button, isPressed) in buttonValues {
                setButton(button, isPressed: isPressed)
            }
            
            sendButtons()
        }
    }
    
    @MainActor
    private func registerNonDpadButtonsHandlers() {
        
        let buttonMappings: [(String, NESButton)] = [
            // Note that we *don't* map the "B" (Xbox-style) button to the NES controller's "B" button, etc
            // TODO: This should respond to the corresponding "Select" and "Start" buttons (and maybe not respond to X/Y) as Select/Start
            (GCInputButtonA, .b),
            (GCInputButtonB, .a),
            (GCInputButtonX, .select),
            (GCInputButtonY, .start)
        ]
        
        for (gcButton, nesButton) in buttonMappings {
            gcController.physicalInputProfile.buttons[gcButton]?.pressedChangedHandler = { [unowned self] button, value, isPressed in
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
