//
//  DisableSystemAlertSoundsView.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/23/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

#if canImport(AppKit)

import SwiftUI
import AppKit

// Adapted from: https://stackoverflow.com/a/73361731/3547802

// TODO: See if macOS 14’s `onKeyPress(_:action:)` can obviate the need for this

/// View that prevents the system alert being played by SwiftUI for all the "unhandled" key presses that `GameController.GCKeyboard` is handling for us
struct DisableSystemAlertSoundsView: NSViewRepresentable {
    
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) { }
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) { }
}

#endif
