//
//  KnowledgePathwayViewModel.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import SwiftUI
import Combine

final class KnowledgePathwayViewModel: ObservableObject {
    @Published private(set) var questions: [TriviaQuestion]
    @Published private(set) var index = 0
    @Published private(set) var correct = 0
    @Published private(set) var isCompleted = false
    @Published private(set) var selectedIndex: Int?

    let difficulty: Difficulty
    private let startedAt = Date()

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.questions = KnowledgePathwayViewModel.makeQuestions(difficulty: difficulty)
    }

    var currentQuestion: TriviaQuestion {
        questions[index]
    }

    func choose(_ answerIndex: Int) {
        guard !isCompleted else { return }
        selectedIndex = answerIndex
        if answerIndex == currentQuestion.answerIndex {
            correct += 1
        }
    }

    func next() {
        guard selectedIndex != nil else { return }
        if index + 1 < questions.count {
            withAnimation(.easeInOut(duration: 0.25)) {
                index += 1
            }
            selectedIndex = nil
        } else {
            isCompleted = true
        }
    }

    func buildResult(attempts: Int) -> ActivityResult {
        let total = questions.count
        let accuracy = Double(correct) / Double(max(total, 1))
        let timeSpent = Date().timeIntervalSince(startedAt)
        let stars: Int
        if accuracy >= threeStarAccuracy && timeSpent <= threeStarTimeLimit { stars = 3 }
        else if accuracy >= twoStarAccuracy { stars = 2 }
        else if accuracy > 0 { stars = 1 }
        else { stars = 0 }
        return ActivityResult(
            activity: .knowledgePathway,
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
        case .easy: return 1.0
        case .normal: return 1.0
        case .hard: return 1.0
        }
    }

    private var twoStarAccuracy: Double {
        switch difficulty {
        case .easy: return 0.5
        case .normal: return 0.67
        case .hard: return 0.75
        }
    }

    private var threeStarTimeLimit: TimeInterval {
        switch difficulty {
        case .easy: return 45
        case .normal: return 55
        case .hard: return 65
        }
    }

    private static func makeQuestions(difficulty: Difficulty) -> [TriviaQuestion] {
        switch difficulty {
        case .easy:
            return [
                TriviaQuestion(prompt: "Which planet is known as the Red Planet?", options: ["Mars", "Venus", "Saturn"], answerIndex: 0),
                TriviaQuestion(prompt: "What is the capital city of France?", options: ["Berlin", "Madrid", "Paris"], answerIndex: 2)
            ]
        case .normal:
            return [
                TriviaQuestion(prompt: "Which scientist proposed the three laws of motion?", options: ["Newton", "Einstein", "Kepler"], answerIndex: 0),
                TriviaQuestion(prompt: "The Renaissance began in which country?", options: ["Spain", "Italy", "Greece"], answerIndex: 1),
                TriviaQuestion(prompt: "Which gas is most abundant in Earth's atmosphere?", options: ["Oxygen", "Hydrogen", "Nitrogen"], answerIndex: 2)
            ]
        case .hard:
            return [
                TriviaQuestion(prompt: "Which treaty ended the Thirty Years' War in 1648?", options: ["Treaty of Utrecht", "Peace of Westphalia", "Treaty of Tordesillas"], answerIndex: 1),
                TriviaQuestion(prompt: "In computing, Big O notation describes what?", options: ["Data storage type", "Algorithmic complexity", "A networking protocol"], answerIndex: 1),
                TriviaQuestion(prompt: "What phenomenon explains apparent bending of light in water?", options: ["Refraction", "Diffusion", "Reflection"], answerIndex: 0),
                TriviaQuestion(prompt: "Which element has atomic number 26?", options: ["Cobalt", "Iron", "Nickel"], answerIndex: 1)
            ]
        }
    }
}
