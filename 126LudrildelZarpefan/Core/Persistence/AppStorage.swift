//
//  AppStorage.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import Combine

final class AppProgressStore: ObservableObject {
    static let resetNotification = Notification.Name("AppProgressResetNotification")

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var starMap: [String: Int]
    @Published private(set) var attemptMap: [String: Int]
    @Published private(set) var totalPlayTime: TimeInterval
    @Published private(set) var totalActivitiesPlayed: Int
    /// Achievement IDs unlocked by the most recent `record` call (for result screen banner).
    @Published private(set) var lastUnlockedAchievementIDs: [String] = []
    @Published private(set) var accuracyMissByActivity: [String: Int]
    @Published private(set) var speedMissByActivity: [String: Int]

    private let defaults: UserDefaults
    private let onboardingKey = "hasSeenOnboarding"
    private let starsKey = "activityStars"
    private let attemptsKey = "activityAttempts"
    private let totalPlayTimeKey = "totalPlayTime"
    private let totalActivitiesKey = "totalActivitiesPlayed"
    private let accuracyMissKey = "accuracyMissByActivity"
    private let speedMissKey = "speedMissByActivity"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasSeenOnboarding = defaults.bool(forKey: onboardingKey)
        self.starMap = defaults.dictionary(forKey: starsKey) as? [String: Int] ?? [:]
        self.attemptMap = defaults.dictionary(forKey: attemptsKey) as? [String: Int] ?? [:]
        self.totalPlayTime = defaults.double(forKey: totalPlayTimeKey)
        self.totalActivitiesPlayed = defaults.integer(forKey: totalActivitiesKey)
        self.accuracyMissByActivity = defaults.dictionary(forKey: accuracyMissKey) as? [String: Int] ?? [:]
        self.speedMissByActivity = defaults.dictionary(forKey: speedMissKey) as? [String: Int] ?? [:]
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: onboardingKey)
    }

    func isUnlocked(_ difficulty: Difficulty) -> Bool {
        switch difficulty {
        case .easy:
            return true
        case .normal:
            return completedActivitiesCount(for: .easy) >= 2
        case .hard:
            return completedActivitiesCount(for: .normal) >= 2
        }
    }

    func stars(for activity: ActivityType, difficulty: Difficulty) -> Int {
        starMap[key(for: activity, difficulty: difficulty)] ?? 0
    }

    func attempts(for activity: ActivityType, difficulty: Difficulty) -> Int {
        attemptMap[key(for: activity, difficulty: difficulty)] ?? 0
    }

    func totalStars(for difficulty: Difficulty) -> Int {
        ActivityType.allCases.reduce(0) { $0 + stars(for: $1, difficulty: difficulty) }
    }

    func completedActivitiesCount(for difficulty: Difficulty) -> Int {
        ActivityType.allCases.filter { stars(for: $0, difficulty: difficulty) > 0 }.count
    }

    var allLevelsCompleted: Bool {
        Difficulty.allCases.allSatisfy { completedActivitiesCount(for: $0) == ActivityType.allCases.count }
    }

    func record(result: ActivityResult) {
        let unlockedBefore = Set(achievements.filter(\.isUnlocked).map(\.id))

        let id = key(for: result.activity, difficulty: result.difficulty)
        starMap[id] = max(starMap[id] ?? 0, result.stars)
        attemptMap[id] = (attemptMap[id] ?? 0) + 1
        totalPlayTime += result.timeSpent
        totalActivitiesPlayed += 1
        registerThreeStarMisses(for: result)
        save()

        let unlockedAfter = Set(achievements.filter(\.isUnlocked).map(\.id))
        lastUnlockedAchievementIDs = Array(unlockedAfter.subtracting(unlockedBefore))
    }

    /// Titles for achievements just unlocked in the last `record`, then clears the pending list.
    func consumeNewlyUnlockedAchievementsForBanner() -> [String] {
        let titles = achievements
            .filter { lastUnlockedAchievementIDs.contains($0.id) && $0.isUnlocked }
            .map(\.title)
        lastUnlockedAchievementIDs = []
        return titles
    }

    /// Next suggested activity after this result: same difficulty → next activity, or first activity of next unlocked difficulty.
    func nextPlayableDestination(after result: ActivityResult) -> (ActivityType, Difficulty)? {
        let activities = ActivityType.allCases
        let difficulties = Difficulty.allCases
        guard let actIndex = activities.firstIndex(of: result.activity),
              let diffIndex = difficulties.firstIndex(of: result.difficulty) else { return nil }

        if actIndex + 1 < activities.count {
            return (activities[actIndex + 1], result.difficulty)
        }
        if diffIndex + 1 < difficulties.count {
            let nextDiff = difficulties[diffIndex + 1]
            guard isUnlocked(nextDiff) else { return nil }
            return (activities[0], nextDiff)
        }
        return nil
    }

    var achievements: [Achievement] {
        [
            Achievement(
                id: "first_star",
                title: "First Star",
                description: "Earn your first star in any challenge.",
                isUnlocked: totalStars >= 1
            ),
            Achievement(
                id: "steady_explorer",
                title: "Steady Explorer",
                description: "Complete 5 activities.",
                isUnlocked: totalActivitiesPlayed >= 5
            ),
            Achievement(
                id: "storm_master",
                title: "Storm Master",
                description: "Earn 3 stars in True or False Storm on Hard.",
                isUnlocked: stars(for: .trueFalseStorm, difficulty: .hard) == 3
            ),
            Achievement(
                id: "odd_detective",
                title: "Odd Detective",
                description: "Earn 3 stars in Odd One Out on Hard.",
                isUnlocked: stars(for: .oddOneOut, difficulty: .hard) == 3
            ),
            Achievement(
                id: "perfect_path",
                title: "Perfect Path",
                description: "Get 3 stars in Knowledge Pathway on Hard.",
                isUnlocked: stars(for: .knowledgePathway, difficulty: .hard) == 3
            ),
            Achievement(
                id: "timeline_ace",
                title: "Timeline Ace",
                description: "Earn 3 stars in Timeline Sprint on Hard.",
                isUnlocked: stars(for: .timelineSprint, difficulty: .hard) == 3
            ),
            Achievement(
                id: "full_constellation",
                title: "Full Constellation",
                description: "Complete all levels in all difficulties.",
                isUnlocked: allLevelsCompleted
            )
        ]
    }

    var totalStars: Int {
        starMap.values.reduce(0, +)
    }

    struct BalanceInsight: Identifiable {
        let id: String
        let activity: ActivityType
        let accuracyMisses: Int
        let speedMisses: Int
        let totalMisses: Int
    }

    var balanceInsights: [BalanceInsight] {
        ActivityType.allCases
            .map { activity in
                let accuracy = accuracyMissByActivity[activity.rawValue] ?? 0
                let speed = speedMissByActivity[activity.rawValue] ?? 0
                return BalanceInsight(
                    id: activity.rawValue,
                    activity: activity,
                    accuracyMisses: accuracy,
                    speedMisses: speed,
                    totalMisses: accuracy + speed
                )
            }
            .filter { $0.totalMisses > 0 }
            .sorted { $0.totalMisses > $1.totalMisses }
    }

    func resetAll() {
        hasSeenOnboarding = false
        starMap = [:]
        attemptMap = [:]
        totalPlayTime = 0
        totalActivitiesPlayed = 0
        lastUnlockedAchievementIDs = []
        accuracyMissByActivity = [:]
        speedMissByActivity = [:]
        defaults.removeObject(forKey: onboardingKey)
        defaults.removeObject(forKey: starsKey)
        defaults.removeObject(forKey: attemptsKey)
        defaults.removeObject(forKey: totalPlayTimeKey)
        defaults.removeObject(forKey: totalActivitiesKey)
        defaults.removeObject(forKey: accuracyMissKey)
        defaults.removeObject(forKey: speedMissKey)
        NotificationCenter.default.post(name: Self.resetNotification, object: nil)
    }

    private func save() {
        defaults.set(starMap, forKey: starsKey)
        defaults.set(attemptMap, forKey: attemptsKey)
        defaults.set(totalPlayTime, forKey: totalPlayTimeKey)
        defaults.set(totalActivitiesPlayed, forKey: totalActivitiesKey)
        defaults.set(accuracyMissByActivity, forKey: accuracyMissKey)
        defaults.set(speedMissByActivity, forKey: speedMissKey)
    }

    private func registerThreeStarMisses(for result: ActivityResult) {
        let requirements = threeStarRequirements(for: result.activity, difficulty: result.difficulty)
        let accuracy = Double(result.correctAnswers) / Double(max(result.totalQuestions, 1))
        let missesAccuracy = accuracy < requirements.requiredAccuracy
        let missesSpeed = requirements.maxTimeAllowed.map { result.timeSpent > $0 } ?? false
        let key = result.activity.rawValue
        if missesAccuracy {
            accuracyMissByActivity[key] = (accuracyMissByActivity[key] ?? 0) + 1
        }
        if missesSpeed {
            speedMissByActivity[key] = (speedMissByActivity[key] ?? 0) + 1
        }
    }

    private func threeStarRequirements(for activity: ActivityType, difficulty: Difficulty) -> (requiredAccuracy: Double, maxTimeAllowed: TimeInterval?) {
        switch activity {
        case .knowledgePathway:
            let maxTime: TimeInterval
            switch difficulty {
            case .easy: maxTime = 45
            case .normal: maxTime = 55
            case .hard: maxTime = 65
            }
            return (1.0, maxTime)
        case .quizTrails:
            let totalTime: TimeInterval
            let minLeft: TimeInterval
            let accuracy: Double
            switch difficulty {
            case .easy:
                totalTime = 75
                minLeft = 15
                accuracy = 0.9
            case .normal:
                totalTime = 55
                minLeft = 12
                accuracy = 1.0
            case .hard:
                totalTime = 38
                minLeft = 10
                accuracy = 1.0
            }
            return (accuracy, totalTime - minLeft)
        case .factHunter:
            return (1.0, nil)
        case .trueFalseStorm:
            let totalTime: TimeInterval
            let minLeft: TimeInterval
            let accuracy: Double
            switch difficulty {
            case .easy:
                totalTime = 42
                minLeft = 10
                accuracy = 0.75
            case .normal:
                totalTime = 30
                minLeft = 8
                accuracy = 0.84
            case .hard:
                totalTime = 18
                minLeft = 5
                accuracy = 0.9
            }
            return (accuracy, totalTime - minLeft)
        case .oddOneOut:
            return (1.0, nil)
        case .timelineSprint:
            return (1.0, nil)
        }
    }

    private func key(for activity: ActivityType, difficulty: Difficulty) -> String {
        "\(activity.rawValue)_\(difficulty.rawValue)"
    }
}
