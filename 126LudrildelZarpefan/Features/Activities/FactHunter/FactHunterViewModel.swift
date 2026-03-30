//
//  FactHunterViewModel.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation
import SwiftUI
import Combine

struct HuntTarget: Identifiable {
    let id = UUID()
    let point: CGPoint
    let question: TriviaQuestion
    var discovered = false
}

final class FactHunterViewModel: ObservableObject {
    @Published var targets: [HuntTarget]
    @Published var selectedTargetID: UUID?
    @Published private(set) var correct = 0
    @Published private(set) var finished = false

    let difficulty: Difficulty
    private let startTime = Date()

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.targets = FactHunterViewModel.makeTargets(difficulty: difficulty)
    }

    var hintRadius: CGFloat {
        switch difficulty {
        case .easy: return 0.18
        case .normal: return 0.10
        case .hard: return 0.06
        }
    }

    func tap(at normalizedPoint: CGPoint) {
        guard !finished else { return }
        for target in targets where !target.discovered {
            let dx = target.point.x - normalizedPoint.x
            let dy = target.point.y - normalizedPoint.y
            let distance = sqrt(dx * dx + dy * dy)
            if distance <= hintRadius {
                selectedTargetID = target.id
                return
            }
        }
    }

    func answerSelected(optionIndex: Int) {
        guard let id = selectedTargetID, let index = targets.firstIndex(where: { $0.id == id }) else { return }
        let question = targets[index].question
        if optionIndex == question.answerIndex {
            correct += 1
        }
        targets[index].discovered = true
        selectedTargetID = nil
        if targets.allSatisfy(\.discovered) {
            finished = true
        }
    }

    func buildResult(attempts: Int) -> ActivityResult {
        let total = targets.count
        let accuracy = Double(correct) / Double(max(total, 1))
        let timeSpent = Date().timeIntervalSince(startTime)
        let stars: Int
        if accuracy >= threeStarAccuracy { stars = 3 }
        else if accuracy >= twoStarAccuracy { stars = 2 }
        else if accuracy > 0 { stars = 1 }
        else { stars = 0 }
        return ActivityResult(
            activity: .factHunter,
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
        case .easy: return 0.67
        case .normal: return 0.75
        case .hard: return 0.8
        }
    }

    var selectedQuestion: TriviaQuestion? {
        guard let id = selectedTargetID else { return nil }
        return targets.first(where: { $0.id == id })?.question
    }

    private static func makeTargets(difficulty: Difficulty) -> [HuntTarget] {
        let base: [HuntTarget] = [
            HuntTarget(point: CGPoint(x: 0.2, y: 0.2), question: TriviaQuestion(prompt: "Which metal is liquid at room temperature?", options: ["Mercury", "Copper", "Iron"], answerIndex: 0)),
            HuntTarget(point: CGPoint(x: 0.7, y: 0.3), question: TriviaQuestion(prompt: "What is the largest mammal?", options: ["Elephant", "Blue whale", "Giraffe"], answerIndex: 1)),
            HuntTarget(point: CGPoint(x: 0.45, y: 0.75), question: TriviaQuestion(prompt: "Which continent is also a country?", options: ["Australia", "Europe", "Africa"], answerIndex: 0)),
            HuntTarget(point: CGPoint(x: 0.82, y: 0.8), question: TriviaQuestion(prompt: "What is H2O commonly called?", options: ["Hydrogen", "Salt", "Water"], answerIndex: 2)),
            HuntTarget(point: CGPoint(x: 0.12, y: 0.62), question: TriviaQuestion(prompt: "Who painted the Mona Lisa?", options: ["Van Gogh", "Da Vinci", "Monet"], answerIndex: 1))
        ]

        switch difficulty {
        case .easy: return Array(base.prefix(3))
        case .normal: return Array(base.prefix(4))
        case .hard: return base
        }
    }
}
