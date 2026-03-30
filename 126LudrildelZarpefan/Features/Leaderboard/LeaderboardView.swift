//
//  LeaderboardView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var store: AppProgressStore

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Score")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Total stars: \(store.totalStars)")
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Activities played: \(store.totalActivitiesPlayed)")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    ForEach(Array(mockRows.enumerated()), id: \.offset) { index, row in
                        SurfaceCard {
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundStyle(Color.appTextSecondary)
                                    .frame(minWidth: 36, alignment: .leading)
                                Text(row.0)
                                    .foregroundStyle(row.0 == "You" ? Color.appAccent : Color.appTextPrimary)
                                Spacer()
                                Text("\(row.1) ★")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Leaderboard")
    }

    private var mockRows: [(String, Int)] {
        let user = ("You", store.totalStars)
        let others = [("Aster", 42), ("Nimbus", 37), ("Questor", 29), ("Atlas", 20)]
        return ([user] + others).sorted { $0.1 > $1.1 }
    }
}
