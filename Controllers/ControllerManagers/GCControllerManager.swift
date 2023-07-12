//
//  GameControllerManager.swift
//  Controllers
//
//  Created by Grady Haynes on 2/27/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import GameController
import AsyncAlgorithms

final class GCControllerManager {
    
    let connectNotifications: NotificationCenter.Notifications
    let disconnectNotifications: NotificationCenter.Notifications
        
    lazy var controllersChannel: AsyncChannel<AsyncChannel<Set<NESButton>>> = {
        buildControllersChannel()
    }()
    
    private var buttonsChannels: [GCControllerButtonsChannel] = []
    
    init(connectNotifications: NotificationCenter.Notifications, disconnectNotifications: NotificationCenter.Notifications) {
        self.connectNotifications = connectNotifications
        self.disconnectNotifications = disconnectNotifications
    }
    
    private func buildControllersChannel() -> AsyncChannel<AsyncChannel<Set<NESButton>>> {
        
        let controllersChannel = AsyncChannel<AsyncChannel<Set<NESButton>>>()
        
        Task {
            for await connection in connectNotifications {
                guard let gcController = connection.object as? GCController else { return }
                                
                // Configure the GCController, which creates a new channel for it that we'll store in buttonsChannels
                let buttonsChannel = await GCControllerButtonsChannel(gcController: gcController)
                buttonsChannels.append(buttonsChannel)

                // Publish it onto controllersChannel
                await controllersChannel.send(buttonsChannel.channel)
            }
        }
        
        Task {
            for await disconnection in disconnectNotifications {
                guard let gcController = disconnection.object as? GCController else { return }
                
                // Remove (and, thus, free) the buttons channel
                guard let buttonsChannelIndex = buttonsChannels.firstIndex(where: { $0.gcController == gcController }) else {
                    assertionFailure("Attempted to free buttons channel that is not connected")
                    return
                }
                buttonsChannels.remove(at: buttonsChannelIndex)
            }
        }
        
        return controllersChannel
    }
}
