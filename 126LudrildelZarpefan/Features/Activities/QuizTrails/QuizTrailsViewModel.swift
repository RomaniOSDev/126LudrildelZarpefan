//
//  QuizTrailsViewModel.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import SwiftUI
import Combine

final class QuizTrailsViewModel: ObservableObject {
    @Published private(set) var questions: [TriviaQuestion]
    @Published private(set) var index = 0
    @Published private(set) var correct = 0
    @Published private(set) var timeLeft: Int
    @Published private(set) var finished = false
    @Published var answeredTitles: [String] = []

    let difficulty: Difficulty
    private let totalTime: Int
    private let startedAt = Date()

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.questions = QuizTrailsViewModel.makeQuestions(difficulty: difficulty)
        switch difficulty {
        case .easy: self.totalTime = 75
        case .normal: self.totalTime = 55
        case .hard: self.totalTime = 38
        }
        self.timeLeft = totalTime
    }

    var initialTime: Int {
        totalTime
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

    func answer(_ optionIndex: Int) {
        guard let currentQuestion, !finished else { return }
        if optionIndex == currentQuestion.answerIndex {
            correct += 1
            answeredTitles.append("Correct: \(currentQuestion.prompt)")
        } else {
            answeredTitles.append("Missed: \(currentQuestion.prompt)")
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            index += 1
            if index >= questions.count {
                finished = true
            }
        }
    }

    func buildResult(attempts: Int) -> ActivityResult {
        let total = questions.count
        let accuracy = Double(correct) / Double(max(total, 1))
        let timeSpent = Date().timeIntervalSince(startedAt)
        let stars: Int
        if accuracy >= threeStarAccuracy && timeLeft >= minTimeLeftForThreeStars { stars = 3 }
        else if accuracy >= twoStarAccuracy { stars = 2 }
        else if accuracy > 0 { stars = 1 }
        else { stars = 0 }
        return ActivityResult(
            activity: .quizTrails,
            difficulty: difficulty,
            stars: stars,
            correctAnswers: correct,
            totalQuestions: total,
            timeSpent: timeSpent,
            attempts: attempts + 1
        )
    }

    private var threeStarAccuracy: Double {
        switch difficulty {
        case .easy: return 0.9
        case .normal: return 1.0
        case .hard: return 1.0
        }
    }

    private var twoStarAccuracy: Double {
        switch difficulty {
        case .easy: return 0.67
        case .normal: return 0.75
        case .hard: return 0.8
        }
    }

    private var minTimeLeftForThreeStars: Int {
        switch difficulty {
        case .easy: return 15
        case .normal: return 12
        case .hard: return 10
        }
    }

    private static func makeQuestions(difficulty: Difficulty) -> [TriviaQuestion] {
        switch difficulty {
        case .easy:
            return [
                TriviaQuestion(prompt: "Which ocean is the largest?", options: ["Pacific", "Atlantic", "Indian"], answerIndex: 0),
                TriviaQuestion(prompt: "How many days are in a leap year?", options: ["366", "364", "360"], answerIndex: 0),
                TriviaQuestion(prompt: "Which animal is known for black-and-white stripes?", options: ["Tiger", "Zebra", "Leopard"], answerIndex: 1)
            ]
        case .normal:
            return [
                TriviaQuestion(prompt: "What is the chemical symbol for gold?", options: ["Gd", "Au", "Ag"], answerIndex: 1),
                TriviaQuestion(prompt: "Who wrote Hamlet?", options: ["Shakespeare", "Marlowe", "Byron"], answerIndex: 0),
                TriviaQuestion(prompt: "Which continent has the most countries?", options: ["Asia", "Africa", "Europe"], answerIndex: 1),
                TriviaQuestion(prompt: "What year did the first human land on the Moon?", options: ["1969", "1972", "1958"], answerIndex: 0)
            ]
        case .hard:
            return [
                TriviaQuestion(prompt: "What is the SI unit of luminous intensity?", options: ["Candela", "Lux", "Lumen"], answerIndex: 0),
                TriviaQuestion(prompt: "Which philosopher wrote The Republic?", options: ["Aristotle", "Plato", "Socrates"], answerIndex: 1),
                TriviaQuestion(prompt: "Which empire used the city of Cusco as a capital?", options: ["Aztec", "Maya", "Inca"], answerIndex: 2),
                TriviaQuestion(prompt: "What is the longest river in Europe?", options: ["Danube", "Volga", "Dnieper"], answerIndex: 1),
                TriviaQuestion(prompt: "What process turns vapor directly into ice?", options: ["Condensation", "Sublimation", "Deposition"], answerIndex: 2)
            ]
        }
    }
}
