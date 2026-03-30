//
//  ExploreView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var store: AppProgressStore

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("New Modes")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            ForEach([ActivityType.trueFalseStorm, .oddOneOut, .timelineSprint], id: \.self) { activity in
                                NavigationLink {
                                    ActivityRouterView(activity: activity, difficulty: .easy)
                                } label: {
                                    HStack {
                                        Text(activity.title)
                                            .foregroundStyle(Color.appTextPrimary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                        Spacer()
                                        Text("Easy")
                                            .font(.caption.bold())
                                            .foregroundStyle(Color.appBackground)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.appAccent)
                                            .clipShape(Capsule())
                                    }
                                    .frame(minHeight: 44)
                                }
                            }
                        }
                    }

                    ForEach(Difficulty.allCases) { difficulty in
                        NavigationLink {
                            DifficultyActivitiesView(difficulty: difficulty)
                        } label: {
                            SurfaceCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(difficulty.title)
                                            .font(.headline)
                                            .foregroundStyle(Color.appTextPrimary)
                                        Text(store.isUnlocked(difficulty) ? "Choose an activity and improve your stars." : "Locked until previous tier is completed.")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.appTextSecondary)
                                    }
                                    Spacer()
                                    if store.isUnlocked(difficulty) {
                                        StarsBadge(stars: store.totalStars(for: difficulty))
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(Color.appTextPrimary)
                                    }
                                }
                            }
                        }
                        .disabled(!store.isUnlocked(difficulty))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Explore")
    }
}

private struct DifficultyActivitiesView: View {
    @EnvironmentObject private var store: AppProgressStore
    let difficulty: Difficulty

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(orderedActivities) { activity in
                        NavigationLink {
                            ActivityRouterView(activity: activity, difficulty: difficulty)
                        } label: {
                            SurfaceCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            Text(activity.title)
                                                .font(.headline)
                                                .foregroundStyle(Color.appTextPrimary)
                                            if activity.isNewMode {
                                                Text("NEW")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(Color.appBackground)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.appAccent)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        Text("Best stars: \(store.stars(for: activity, difficulty: difficulty))/3")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.appTextSecondary)
                                    }
                                    Spacer()
                                    StarsRow(stars: store.stars(for: activity, difficulty: difficulty))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(difficulty.title)
    }

    private var orderedActivities: [ActivityType] {
        ActivityType.allCases.sorted { lhs, rhs in
            let lNew = lhs.isNewMode ? 0 : 1
            let rNew = rhs.isNewMode ? 0 : 1
            if lNew != rNew { return lNew < rNew }
            return lhs.title < rhs.title
        }
    }
}

struct ActivityRouterView: View {
    let activity: ActivityType
    let difficulty: Difficulty

    var body: some View {
        switch activity {
        case .knowledgePathway:
            KnowledgePathwayView(difficulty: difficulty)
        case .quizTrails:
            QuizTrailsView(difficulty: difficulty)
        case .factHunter:
            FactHunterView(difficulty: difficulty)
        case .trueFalseStorm:
            TrueFalseStormView(difficulty: difficulty)
        case .oddOneOut:
            OddOneOutView(difficulty: difficulty)
        case .timelineSprint:
            TimelineSprintView(difficulty: difficulty)
        }
    }
}

private struct StarsBadge: View {
    let stars: Int

    var body: some View {
        Text("\(stars) ★")
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appPrimary)
            .clipShape(Capsule())
    }
}

struct StarsRow: View {
    let stars: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .foregroundStyle(index < stars ? Color.appAccent : Color.appTextSecondary)
            }
        }
    }
}

private extension ActivityType {
    var isNewMode: Bool {
        switch self {
        case .trueFalseStorm, .oddOneOut, .timelineSprint:
            return true
        default:
            return false
        }
    }
}
