//
//  AboutView.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/5/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    
    private static let appVersion = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }()
    
    private static let about = try! AttributedString(
        markdown: """
            
            **Blackbox** (v\(appVersion)) by Grady Haynes
            
            
            Nintendo Entertainment System (NES) emulator
            for iOS, iPadOS, macOS, and visionOS written in Swift
            
            **[Project Page](https://github.com/glhaynes/Blackbox)**
            
            Blackbox is distributed under the [MIT License](https://en.wikipedia.org/wiki/MIT_License).
            
            """,
        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
    
    var body: some View {
        // TODO: Consider using this and just rendering the README.md? https://github.com/gonzalezreal/swift-markdown-ui
        Text(Self.about)
            .multilineTextAlignment(.center)
            .tint(.accentColor)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
