//
//  ContentView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI
import Network

struct ContentView: View {
    @State private var requestNotifications = true
    @State private var somethingWentWrong = false
    @State private var supportMessage = ""
    @StateObject private var store = AppProgressStore()

    var body: some View {
        Group {
            if requestNotifications {
                ZarpefanLoadingView()
            } else {
                if somethingWentWrong {
                    ZarpefanUpdateManager.ZarpefanUpdateManagerUI(ZarpefanUpdateManagerInfo: supportMessage)
                        .ignoresSafeArea()
                } else {
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
        }
        .onAppear {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                if path.status != .satisfied {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue.global(qos: .utility))

            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RemMess"),
                object: nil,
                queue: .main
            ) { notification in
                if let info = notification.userInfo as? [String: String],
                   let data = info["notificationMessage"] {
                    Task { @MainActor in
                        if data == "Error occurred" {
                            self.somethingWentWrong = false
                        } else {
                            self.supportMessage = data
                            self.somethingWentWrong = true
                        }
                        self.requestNotifications = false
                    }
                } else {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}



struct ZarpefanLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("appIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding(.top, 30)
            }
        }
    }
}
