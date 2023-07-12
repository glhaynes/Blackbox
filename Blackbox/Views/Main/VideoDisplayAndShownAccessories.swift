//
//  VideoDisplayAndShownAccessories.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/3/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct VideoDisplayAndShownAccessories: View {
    
    @Namespace private var matchedViews
        
    #if os(macOS)
    // This is required to make animation work on macOS. There's likely a better way.
    @State private var areAccessoriesShownAsState = false
    #endif
    
    let areAccessoriesShown: Bool
    let gameScreenScale: Double
    
    var body: some View {
        videoDisplayAndShownAccessories
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #if os(macOS)
            .onAppear {
                areAccessoriesShownAsState = areAccessoriesShown
            }
            .onChange(of: areAccessoriesShown) { isShown in
                withAnimation { areAccessoriesShownAsState = isShown }
            }
            #endif
    }
    
    // MARK: Video Display and Accessories
    
    @ViewBuilder
    private var videoDisplayAndShownAccessories: some View {
        #if os(macOS)
        let accessoriesShown = areAccessoriesShownAsState
        #else
        let accessoriesShown = areAccessoriesShown
        #endif
        
        HStack(spacing: 0) {
            if accessoriesShown {
                videoDisplay()
                    .aspectRatio(8.0/7, contentMode: .fit)
                    .padding()
                    .layoutPriority(1)

                Spacer(minLength: 0)
                
                accessories()
                    .frame(minWidth: 175)
            } else {
                videoDisplay()
                    .aspectRatio(8.0/7, contentMode: .fit)
                    #if !os(macOS)
                    .ignoresSafeArea()
                    #endif
            }
        }
    }

    @ViewBuilder
    private func videoDisplay(matchedGeometryEffectId: String = "videoDisplay") -> some View {
        let isOnlyVideoShown = !areAccessoriesShown  // || (fitting == .onlyVideoDisplay)
        let cornerRadius = isOnlyVideoShown ? 0.0 : 10.0
        VideoDisplay(cornerRadius: cornerRadius)
            .matchedGeometryEffect(id: matchedGeometryEffectId, in: matchedViews)
            .transition(.asymmetric(insertion: .identity, removal: .identity))
            .scaleEffect(gameScreenScale)
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func accessories(matchedGeometryEffectId: String = "accessories") -> some View {
        Accessories()
            .matchedGeometryEffect(id: matchedGeometryEffectId, in: matchedViews)
            .transition(.move(edge: .trailing))
            .frame(maxHeight: .infinity)
    }
}
