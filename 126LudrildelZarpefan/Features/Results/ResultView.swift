//
//  ResultView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var store: AppProgressStore
    @Environment(\.dismiss) private var dismiss

    let result: ActivityResult

    @State private var visibleStars = 0
    @State private var bannerTitles: [String] = []
    @State private var showBanner = false

    private var nextDestination: (ActivityType, Difficulty)? {
        store.nextPlayableDestination(after: result)
    }

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    if showBanner && !bannerTitles.isEmpty {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(bannerTitles.count > 1 ? "Achievements unlocked" : "Achievement unlocked")
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                                ForEach(bannerTitles, id: \.self) { title in
                                    Text(title)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    SurfaceCard {
                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < visibleStars ? "star.fill" : "star")
                                    .font(.system(size: 34))
                                    .foregroundStyle(index < visibleStars ? Color.appAccent : Color.appTextSecondary)
                                    .shadow(color: index < visibleStars ? .appAccent.opacity(0.8) : .clear, radius: 8)
                                    .scaleEffect(index < visibleStars ? 1 : 0.7)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Activity Stats")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Accuracy: \(result.correctAnswers)/\(result.totalQuestions)")
                                .foregroundStyle(Color.appTextSecondary)
                            Text(String(format: "Time: %.1f sec", result.timeSpent))
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Attempt: \(result.attempts)")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    if let next = nextDestination {
                        NavigationLink("Next Level") {
                            ActivityRouterView(activity: next.0, difficulty: next.1)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    NavigationLink("Retry") {
                        ActivityRouterView(activity: result.activity, difficulty: result.difficulty)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Back to Explore") {
                        popToExploreRoot()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            bannerTitles = store.consumeNewlyUnlockedAchievementsForBanner()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showBanner = !bannerTitles.isEmpty
            }
            animateStars()
        }
    }

    private func popToExploreRoot() {
        Task { @MainActor in
            for _ in 0..<3 {
                dismiss()
                try? await Task.sleep(nanoseconds: 45_000_000)
            }
        }
    }

    private func animateStars() {
        visibleStars = 0
        for index in 0..<result.stars {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * Double(index)) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    visibleStars = index + 1
                }
            }
        }
    }
}
