//
//  WelcomeView.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/3/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    
    enum Page: String, SelectablePage {
        case first = "Blackbox",
             gameControllers = "Game Controllers",
             keyboard = "Keyboard",
             onscreenController = "Other",
             limitations = "Limitations",
             gameROMs = "Games (ROMs)"
    }
        
    @State private var selectedPage: Page = .first
    @State private var selectedControllerKind: GameControllersPage.ControllerKind = .nintendo

    @Environment(\.dismiss) private var dismiss
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #else
    // TODO: On macOS ≥ 14, this is no longer needed
    // TODO: In the meantime, consider replacing with this: https://mastodon.social/@lightandshadow/110515168557081092
    let horizontalSizeClass: MacOSStubSizeClass = .regular
    let verticalSizeClass: MacOSStubSizeClass = .regular
    #endif
    
    #if os(macOS)
    let pages: [Page] = [
        .first,
        .gameControllers,
        .keyboard,
        .limitations,
        .gameROMs
    ]
    #else
    let pages: [Page] = [
        .first,
        .gameControllers,
        .keyboard,
        .onscreenController,
        .limitations,
        .gameROMs
    ]
    #endif
    
    func view(for page: Page) -> any View {
        let spacing: CGFloat = verticalSizeClass == .compact ? 10 : 40
        switch page {
        case .first:
            return TitlePage(spacing: spacing)
        case .gameControllers:
            return GameControllersPage(selectedControllerKind: $selectedControllerKind, spacing: spacing)
        case .keyboard:
            return KeyboardPage(spacing: spacing)
        case .onscreenController:
            return OnscreenControllerPage()
        case .limitations:
            return LimitationsPage()
        case .gameROMs:
            return GameROMsPage()
        }
    }
    
    #if os(macOS)
    @ViewBuilder
    var body: some View {
        VStack {
            PageSelector<Page>(pages: pages, selectedPage: $selectedPage)
            Divider()
            Spacer()
        }
        .background {
            Form {
                AnyView(view(for: selectedPage))
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task { @MainActor in
                        dismiss()
                    }
                } label: {
                    Text("Dismiss")
                }
            }
        }
    }
    #endif
    
    #if os(iOS)
    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(pages, id: \.self) { page in
                AnyView(view(for: page))
                    .tabItem { Text(page.rawValue) }

            }
        }
        .tabViewStyle(.page)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss")
                }
            }
        }
    }
    #endif
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
