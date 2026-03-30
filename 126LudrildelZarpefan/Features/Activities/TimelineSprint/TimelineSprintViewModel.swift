//
//  TimelineSprintViewModel.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import Combine
import SwiftUI

final class TimelineSprintViewModel: ObservableObject {
    @Published private(set) var events: [TimelineEvent]
    @Published var arranged: [TimelineEvent]
    @Published private(set) var submitted = false
    @Published private(set) var correctCount = 0

    let difficulty: Difficulty
    private let startedAt = Date()

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        let generated = Self.makeEvents(difficulty: difficulty)
        self.events = generated
        self.arranged = generated.shuffled()
    }

    func move(from source: IndexSet, to destination: Int) {
        arranged.move(fromOffsets: source, toOffset: destination)
    }

    func submit() {
        guard !submitted else { return }
        let sorted = events.sorted { $0.year < $1.year }
        correctCount = zip(arranged, sorted).filter { $0.year == $1.year }.count
        submitted = true
    }

    func buildResult(attempts: Int) -> ActivityResult {
        let total = arranged.count
        let accuracy = Double(correctCount) / Double(max(total, 1))
        let stars: Int
        if accuracy >= threeStarAccuracy { stars = 3 }
        else if accuracy >= twoStarAccuracy { stars = 2 }
        else if accuracy > 0 { stars = 1 }
        else { stars = 0 }
        return ActivityResult(
            activity: .timelineSprint,
            difficulty: difficulty,
            stars: stars,
            correctAnswers: correctCount,
            totalQuestions: total,
            timeSpent: Date().timeIntervalSince(startedAt),
            attempts: attempts + 1
        )
    }

    private var threeStarAccuracy: Double {
        switch difficulty {
        case .easy: return 1.0
        case .normal: return 1.0
        case .hard: return 1.0
        }
    }

    private var twoStarAccuracy: Double {
        switch difficulty {
        case .easy: return 0.67
        case .normal: return 0.8
        case .hard: return 0.86
        }
    }

    private static func makeEvents(difficulty: Difficulty) -> [TimelineEvent] {
        let easy = [
            TimelineEvent(title: "First Moon Landing", year: 1969),
            TimelineEvent(title: "World Wide Web Proposed", year: 1989),
            TimelineEvent(title: "First iPhone Released", year: 2007)
        ]
        let normal = easy + [
            TimelineEvent(title: "Berlin Wall Falls", year: 1989),
            TimelineEvent(title: "DNA Double Helix Published", year: 1953)
        ]
        let hard = normal + [
            TimelineEvent(title: "Magna Carta Signed", year: 1215),
            TimelineEvent(title: "Printing Press Introduced in Europe", year: 1450)
        ]
        switch difficulty {
        case .easy: return easy
        case .normal: return normal
        case .hard: return hard
        }
    }
}
