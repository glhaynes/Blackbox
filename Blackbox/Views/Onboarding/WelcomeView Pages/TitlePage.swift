//
//  TitlePage.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/21/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct TitlePage: View {
    
    let spacing: CGFloat
    
    var body: some View {
        VStack(spacing: spacing) {
            VStack {
                Image(systemName: "shippingbox")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.accentColor)
                
                Text("Blackbox")
                    .font(.largeTitle)
                    .bold()
            }
            
            Text("NES Emulator for iPhone, iPad, Mac, and Vision Pro")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
            
            #if !os(macOS)
            Text("Swipe to Continue")
                .opacity(0.3)
            #endif
        }
        .offset(y: -15)
    }
}
