//
//  GameControllerCoordinator.swift
//  Controllers
//
//  Created by Grady Haynes on 10/10/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

// TODO: Reconsider usage of `AsyncChannel` (from the `AsyncAlgorithms` package) here.
// I initially used `AsyncStream` from the standard library here, but, despite that working, I didn't feel confident in the safety of passing the continuation its initializer provides outside of that scope. [SE-0388](https://github.com/apple/swift-evolution/blob/main/proposals/0388-async-stream-factory.md) implies that this is safe, though. So, I switched to `AsyncChannel` and prefer the way this code is structured. Still, once SE-0388 lands with the new `AsyncStream.makeStream`, it may make sense to switch back to that just to reduce our dependency count.
// See also discussion on why we don't return a type-erased (and thus implementation-hiding) `AnyAsyncSequence` (which doesn't exist) here: https://forums.swift.org/t/anyasyncsequence/50828/26

// TODO: Maybe all of this should be an Actor. Or at least @MainActor?

import os.log
import Combine
import CoreBlackbox

public final class GameControllerCoordinator: ObservableObject {
    
    private enum Log: String {
        case gameControllerCoordinatorStartup
        case gameControllerConnection
        case keyboardConnection
        case gameControllerOrKeyboardDisconnection
        case onscreenControllerConnection
        case onscreenControllerDisconnection
    }
    
    public struct Notifications {
        let controllerDidConnect: NotificationCenter.Notifications
        let controllerDidDisconnect: NotificationCenter.Notifications
        let keyboardDidConnect: NotificationCenter.Notifications
        let keyboardDidDisconnect: NotificationCenter.Notifications
        
        public init(controllerDidConnect: NotificationCenter.Notifications,
             controllerDidDisconnect: NotificationCenter.Notifications,
             keyboardDidConnect: NotificationCenter.Notifications,
             keyboardDidDisconnect: NotificationCenter.Notifications) {
            self.controllerDidConnect = controllerDidConnect
            self.controllerDidDisconnect = controllerDidDisconnect
            self.keyboardDidConnect = keyboardDidConnect
            self.keyboardDidDisconnect = keyboardDidDisconnect
        }
    }
    
    @Published public var shouldOnscreenControllerBeShown = false

    public var nesControllers: [NESController] = [NESController()] {
        didSet { reconfigure() }
    }
        
    private let gcControllerManager: GCControllerManager
    private let gcKeyboardManager: GCKeyboardManager
    private let logger: Logger?
    
    private var connectedControllerCount = 0
    private var controllersHandler: Task<Void, Never>?
    private var keyboardsHandler: Task<Void, Never>?
    private var onscreenControllerHandler: Task<Void, Never>?
    
    public init(notifications: Notifications, logger: Logger? = nil) {
        self.logger = logger
        defer {
            logInfoPublicly(Log.gameControllerCoordinatorStartup)
        }
        
        self.gcControllerManager = GCControllerManager(connectNotifications: notifications.controllerDidConnect, disconnectNotifications: notifications.controllerDidDisconnect)
        self.gcKeyboardManager = GCKeyboardManager(connectNotifications: notifications.keyboardDidConnect, disconnectNotifications: notifications.keyboardDidDisconnect)
        
        // Add a slight delay so that the controller managers can come online and send us the appropriate connections if we're starting with attached devices. That way we don't get an unsightly flash of the onscreen controller unnecessarily at startup.
        // TODO: Come up with a better way to achieve the same effect.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.reconfigure()
        }
        
        controllersHandler = Task { @MainActor in
            for await controller in gcControllerManager.controllersChannel {
                guard !Task.isCancelled else { return }
                logInfoPublicly(.gameControllerConnection)
                handleButtonStream(controller)
            }
        }
        
        keyboardsHandler = Task { @MainActor in
            for await keyboard in gcKeyboardManager.keyboardsChannel {
                guard !Task.isCancelled else { return }
                logInfoPublicly(.keyboardConnection)
                handleButtonStream(keyboard)
            }
        }
    }

    public func setOnscreenControllerPublisher(_ publisher: some Publisher<Set<NESButton>, Never>) {
        // TODO: Use an `AsyncSequence` instead of Combine
        // - Remember to remove `import Combine`s that are no longer needed
        logInfoPublicly(.onscreenControllerConnection)
        onscreenControllerHandler = Task { @MainActor in
            for await pressed in publisher.values {
                nesControllers.first?.pressedButtons = pressed.nesControllerButtons
            }
            logInfoPublicly(.onscreenControllerDisconnection)
        }
    }
    
    private func reconfigure() {
        Task { @MainActor in
            shouldOnscreenControllerBeShown = connectedControllerCount == 0
        }
    }

    // TODO: Rename this to reflect what it's really doing
    private func handleButtonStream<S: AsyncSequence>(_ stream: S) where S.Element == Set<NESButton> {
        connectedControllerCount += 1
        reconfigure()
        
        // TODO: I don't think this Task will ever get cancelled...
        
        Task {
            do {
                for try await pressedButtons in stream {
                    // When we add 2-player support and/or assignment of controllers, we'll need to make this more sophisticated than just writing to `.first`
                    nesControllers.first?.pressedButtons = pressedButtons.nesControllerButtons
                }
            } catch {
                print("Unexpected error thrown by button stream is unhandled")
            }
                        
            // The stream has closed because the game controller or keyboard has disconnected
            logInfoPublicly(.gameControllerOrKeyboardDisconnection)
            connectedControllerCount -= 1
            reconfigure()
        }
    }
    
    private func logInfoPublicly(_ log: Log) {
        logger?.info("\(log.rawValue, privacy: .public)")
    }
}

private extension NESButton {
    var nesControllerButton: NESController.Button {
        switch self {
        case .a: return .a
        case .b: return .b
        case .select: return .select
        case .start: return .start
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        }
    }
}

private extension Set<NESButton> {
    var nesControllerButtons: Set<NESController.Button> {
        .init(map { $0.nesControllerButton })
    }
}
