//
//  SettingsView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI
import UIKit
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppProgressStore

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Manage feedback, legal pages, and your progress.")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Stats")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Total stars: \(store.totalStars)")
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Activities played: \(store.totalActivitiesPlayed)")
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Play time: \(formatted(duration: store.totalPlayTime))")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    Button("Rate Us") {
                        rateApp()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Privacy Policy") {
                        openLink(.privacyPolicy)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Terms of Use") {
                        openLink(.termsOfUse)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Reset All Progress") {
                        store.resetAll()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Settings")
    }

    private func openLink(_ link: ExternalLinks) {
        if let url = URL(string: link.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func formatted(duration: TimeInterval) -> String {
        if duration <= 0 { return "0m 0s" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}
