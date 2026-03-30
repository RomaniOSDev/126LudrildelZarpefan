//
//  TrueFalseStormViewModel.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import Combine

final class TrueFalseStormViewModel: ObservableObject {
    @Published private(set) var questions: [TriviaQuestion]
    @Published private(set) var index = 0
    @Published private(set) var correct = 0
    @Published private(set) var timeLeft: Int
    @Published private(set) var finished = false

    let difficulty: Difficulty
    private let totalTime: Int
    private let startedAt = Date()

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.questions = Self.makeQuestions(difficulty: difficulty)
        switch difficulty {
        case .easy: totalTime = 42
        case .normal: totalTime = 30
        case .hard: totalTime = 18
        }
        self.timeLeft = totalTime
    }

    var currentQuestion: TriviaQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    func tick() {
        guard !finished else { return }
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            finished = true
        }
    }

    func answerTrueFalse(_ isTrue: Bool) {
        guard let question = currentQuestion, !finished else { return }
        let chosen = isTrue ? 0 : 1
        if chosen == question.answerIndex {
            correct += 1
        }
        index += 1
        if index >= questions.count {
            finished = true
        }
    }

    func buildResult(attempts: Int) -> ActivityResult {
        let total = questions.count
        let accuracy = Double(correct) / Double(max(total, 1))
        let stars: Int
        if accuracy >= threeStarAccuracy && timeLeft >= minTimeLeftForThreeStars { stars = 3 }
        else if accuracy >= twoStarAccuracy { stars = 2 }
        else if accuracy > 0 { stars = 1 }
        else { stars = 0 }
        return ActivityResult(
            activity: .trueFalseStorm,
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
        case .easy: return 0.75
        case .normal: return 0.84
        case .hard: return 0.9
        }
    }

    private var twoStarAccuracy: Double {
        switch difficulty {
        case .easy: return 0.5
        case .normal: return 0.67
        case .hard: return 0.75
        }
    }

    private var minTimeLeftForThreeStars: Int {
        switch difficulty {
        case .easy: return 10
        case .normal: return 8
        case .hard: return 5
        }
    }

    private static func makeQuestions(difficulty: Difficulty) -> [TriviaQuestion] {
        let easy = [
            TriviaQuestion(prompt: "The Pacific is the largest ocean.", options: ["True", "False"], answerIndex: 0),
            TriviaQuestion(prompt: "Humans have three hearts.", options: ["True", "False"], answerIndex: 1),
            TriviaQuestion(prompt: "The Sun is a star.", options: ["True", "False"], answerIndex: 0),
            TriviaQuestion(prompt: "Water boils below freezing point.", options: ["True", "False"], answerIndex: 1)
        ]
        let normal = easy + [
            TriviaQuestion(prompt: "The Great Wall of China is visible from the Moon with the naked eye.", options: ["True", "False"], answerIndex: 1),
            TriviaQuestion(prompt: "Lightning is hotter than the surface of the Sun.", options: ["True", "False"], answerIndex: 0)
        ]
        let hard = normal + [
            TriviaQuestion(prompt: "Sound travels faster in steel than in air.", options: ["True", "False"], answerIndex: 0),
            TriviaQuestion(prompt: "Neptune is closer to the Sun than Uranus.", options: ["True", "False"], answerIndex: 1)
        ]
        switch difficulty {
        case .easy: return easy
        case .normal: return normal
        case .hard: return hard
        }
    }
}
