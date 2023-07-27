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
        **Blackbox**
        
        Nintendo Entertainment System (NES) emulator for Apple platforms

        This app is a work in progress by Grady Haynes. Its [source code is freely available](https://github.com/glhaynes/Blackbox) under the MIT license. Feedback and contributions are welcomed.
        
        """
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
