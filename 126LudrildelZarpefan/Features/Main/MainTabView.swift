//
//  MainTabView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "AppSurface")
        appearance.shadowColor = UIColor(named: "AppAccent")?.withAlphaComponent(0.35)

        let itemAppearance = UITabBarItemAppearance()
        if let primary = UIColor(named: "AppPrimary"), let secondary = UIColor(named: "AppTextSecondary") {
            itemAppearance.normal.iconColor = secondary
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: secondary]
            itemAppearance.selected.iconColor = primary
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: primary]
        }
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label("Explore", systemImage: "map")
            }

            NavigationStack {
                LeaderboardView()
            }
            .tabItem {
                Label("Leaderboard", systemImage: "list.number")
            }

            NavigationStack {
                AchievementsView()
            }
            .tabItem {
                Label("Achievements", systemImage: "star.circle")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(.appPrimary)
    }
}
