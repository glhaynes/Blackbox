//
//  BlackboxApp.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/29/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import SwiftUI
import CoreBlackbox
import Controllers

@main
struct BlackboxApp: App {
        
    private static let appLogger = Logger(subsystem: "com.wordparts.Blackbox", category: "App")
    private static let loggers: NESBuilder.Loggers = [
        // Could also pass: cpu, ppu, apu, bus, ram
        .controller: Logger(subsystem: "com.wordparts.Blackbox", category: "Controller")
    ]

    private static var gameControllerCoordinator = {
        let nc = NotificationCenter.default
        let notifications = GameControllerCoordinator.Notifications(
            controllerDidConnect: nc.notifications(named: .GCControllerDidConnect),
            controllerDidDisconnect: nc.notifications(named: .GCControllerDidDisconnect),
            keyboardDidConnect: nc.notifications(named: .GCKeyboardDidConnect),
            keyboardDidDisconnect: nc.notifications(named: .GCKeyboardDidDisconnect)
        )
        return GameControllerCoordinator(notifications: notifications, logger: loggers[.controller])
    }()
        
    var body: some Scene {

        // TODO: Play with windowResizability, defaultSize, etc
        // - https://developer.apple.com/documentation/swiftui/windowresizability
        // - https://developer.apple.com/documentation/swiftui/scene/defaultsize(_:)
        
        MainScene(gameControllerCoordinator: Self.gameControllerCoordinator,
                  appLogger: Self.appLogger,
                  loggers: Self.loggers)
        
        #if os(macOS)
        Window("About Blackbox", id: "About") {
            AboutView()
                .padding()
                .fixedSize()
        }
        .windowResizability(.contentSize)
        #endif
    }
}
