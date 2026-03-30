//
//  OddOneOutViewModel.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import Combine
import SwiftUI

final class OddOneOutViewModel: ObservableObject {
    @Published private(set) var rounds: [TriviaQuestion]
    @Published private(set) var index = 0
    @Published private(set) var correct = 0
    @Published private(set) var finished = false

    let difficulty: Difficulty
    private let startedAt = Date()

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.rounds = Self.makeRounds(difficulty: difficulty)
    }

    var currentRound: TriviaQuestion? {
        guard index < rounds.count else { return nil }
        return rounds[index]
    }

    func answer(_ optionIndex: Int) {
        guard let round = currentRound, !finished else { return }
        if optionIndex == round.answerIndex {
            correct += 1
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            index += 1
        }
        if index >= rounds.count {
            finished = true
        }
    }

    func buildResult(attempts: Int) -> ActivityResult {
        let total = rounds.count
        let accuracy = Double(correct) / Double(max(total, 1))
        let stars: Int
        if accuracy >= threeStarAccuracy { stars = 3 }
        else if accuracy >= twoStarAccuracy { stars = 2 }
        else if accuracy > 0 { stars = 1 }
        else { stars = 0 }
        return ActivityResult(
            activity: .oddOneOut,
            difficulty: difficulty,
            stars: stars,
            correctAnswers: correct,
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

    private static func makeRounds(difficulty: Difficulty) -> [TriviaQuestion] {
        let easy = [
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["Mercury", "Venus", "Berlin", "Mars"], answerIndex: 2),
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["Triangle", "Square", "Circle", "Oxygen"], answerIndex: 3),
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["January", "April", "Blue", "October"], answerIndex: 2),
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["Copper", "Silver", "Gold", "Sahara"], answerIndex: 3)
        ]
        let normal = easy + [
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["DNA", "RNA", "ATP", "Wi-Fi"], answerIndex: 3),
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["Sahara", "Gobi", "Amazon", "Kalahari"], answerIndex: 2)
        ]
        let hard = normal + [
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["Baroque", "Renaissance", "Romanticism", "Photosynthesis"], answerIndex: 3),
            TriviaQuestion(prompt: "Pick the odd one out:", options: ["Mitosis", "Meiosis", "Osmosis", "Longitude"], answerIndex: 3)
        ]
        switch difficulty {
        case .easy: return easy
        case .normal: return normal
        case .hard: return hard
        }
    }
}
