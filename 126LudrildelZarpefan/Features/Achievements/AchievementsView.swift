//
//  AchievementsView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppProgressStore

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stats")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Total stars: \(store.totalStars)")
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Total play time: \(formatted(duration: store.totalPlayTime))")
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Activities played: \(store.totalActivitiesPlayed)")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Balance Insights")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            if store.balanceInsights.isEmpty {
                                Text("No misses tracked yet. Play more to see accuracy and speed patterns.")
                                    .foregroundStyle(Color.appTextSecondary)
                                    .font(.footnote)
                            } else {
                                ForEach(store.balanceInsights.prefix(3)) { insight in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(insight.activity.title)
                                            .foregroundStyle(Color.appTextPrimary)
                                            .font(.subheadline.bold())
                                        Text("Accuracy misses: \(insight.accuracyMisses)  •  Speed misses: \(insight.speedMisses)")
                                            .foregroundStyle(Color.appTextSecondary)
                                            .font(.footnote)
                                        HStack(spacing: 8) {
                                            GeometryReader { geo in
                                                let total = CGFloat(max(insight.totalMisses, 1))
                                                let accuracyRatio = CGFloat(insight.accuracyMisses) / total
                                                let speedRatio = CGFloat(insight.speedMisses) / total
                                                let width = geo.size.width
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.appSurface.opacity(0.55))
                                                    HStack(spacing: 0) {
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .fill(Color.appPrimary)
                                                            .frame(width: width * accuracyRatio)
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .fill(Color.appAccent)
                                                            .frame(width: width * speedRatio)
                                                    }
                                                }
                                            }
                                            .frame(height: 10)
                                            Text("\(insight.totalMisses)")
                                                .foregroundStyle(Color.appTextSecondary)
                                                .font(.caption)
                                                .frame(minWidth: 22, alignment: .trailing)
                                        }
                                        HStack(spacing: 12) {
                                            Label("Accuracy", systemImage: "circle.fill")
                                                .font(.caption2)
                                                .foregroundStyle(Color.appPrimary)
                                            Label("Speed", systemImage: "circle.fill")
                                                .font(.caption2)
                                                .foregroundStyle(Color.appAccent)
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                        }
                    }

                    ForEach(store.achievements) { item in
                        SurfaceCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .foregroundStyle(Color.appTextPrimary)
                                        .font(.headline)
                                    Text(item.description)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .font(.footnote)
                                }
                                Spacer()
                                Image(systemName: item.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                                    .foregroundStyle(item.isUnlocked ? Color.appAccent : Color.appTextSecondary)
                            }
                        }
                    }

                    Button("Reset All Progress") {
                        store.resetAll()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Achievements")
    }

    private func formatted(duration: TimeInterval) -> String {
        if duration <= 0 { return "0m 0s" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}
