//
//  AboutView.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/5/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        // TODO: Consider using this and just rendering the README.md? https://github.com/gonzalezreal/swift-markdown-ui
        Text(about)
            .multilineTextAlignment(.leading)
            .tint(.accentColor)
    }
    
    private let about: LocalizedStringKey = """
        **Blackbox** by Grady Haynes
        
        Nintendo Entertainment System (NES) emulator for iOS, iPadOS, macOS, and visionOS written in Swift
        
        [Project page](https://github.com/glhaynes/Blackbox) on GitHub
        """
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
