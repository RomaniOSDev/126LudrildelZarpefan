//
//  ContentView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppProgressStore()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
                    .environmentObject(store)
            } else {
                OnboardingView {
                    store.markOnboardingSeen()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
