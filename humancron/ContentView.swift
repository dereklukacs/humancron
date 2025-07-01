//
//  ContentView.swift
//  humancron
//
//  Created by obsess on 6/30/25.
//

import SwiftUI
import DesignSystem

struct ContentView: View {
    @State private var showGallery = false
    
    var body: some View {
        VStack {
            if showGallery {
                DesignSystemGallery()
            } else {
                DesignSystemExample()
            }
        }
        .toolbar {
            ToolbarItem {
                Button(showGallery ? "Show Example" : "Show Gallery") {
                    showGallery.toggle()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
