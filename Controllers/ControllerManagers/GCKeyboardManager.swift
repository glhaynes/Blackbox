//
//  GCKeyboardManager.swift
//  Controllers
//
//  Created by Grady Haynes on 2/27/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import GameController
import AsyncAlgorithms

final class GCKeyboardManager {
    
    let connectNotifications: NotificationCenter.Notifications
    let disconnectNotifications: NotificationCenter.Notifications
        
    lazy var keyboardsChannel: AsyncChannel<AsyncChannel<Set<NESButton>>> = {
        buildKeyboardsChannel()
    }()
    
    private var buttonsChannels: [GCKeyboardButtonsChannel] = []
    
    init(connectNotifications: NotificationCenter.Notifications, disconnectNotifications: NotificationCenter.Notifications) {
        self.connectNotifications = connectNotifications
        self.disconnectNotifications = disconnectNotifications
    }
    
    private func buildKeyboardsChannel() -> AsyncChannel<AsyncChannel<Set<NESButton>>> {
        
        let controllersChannel = AsyncChannel<AsyncChannel<Set<NESButton>>>()
        
        Task {
            for await connection in connectNotifications {
                guard let gcKeyboard = connection.object as? GCKeyboard else { return }
                                
                // Configure the GCKeyboard, which creates a new channel for it that we'll store in buttonsChannels
                let buttonsChannel = await GCKeyboardButtonsChannel(gcKeyboard: gcKeyboard)
                buttonsChannels.append(buttonsChannel)

                // Publish it onto controllersChannel
                await controllersChannel.send(buttonsChannel.channel)
            }
        }
        
        Task {
            for await disconnection in disconnectNotifications {
                guard let gcKeyboard = disconnection.object as? GCKeyboard else { return }
                
                // Remove (and, thus, free) the buttons channel
                guard let buttonsChannelIndex = buttonsChannels.firstIndex(where: { $0.gcKeyboard == gcKeyboard }) else {
                    assertionFailure("Attempted to free buttons channel that is not connected")
                    return
                }
                buttonsChannels.remove(at: buttonsChannelIndex)
            }
        }
        
        return controllersChannel
    }
}
