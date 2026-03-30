//
//  TriviaModels.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import Foundation

enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}

enum ActivityType: String, CaseIterable, Codable, Identifiable {
    case knowledgePathway
    case quizTrails
    case factHunter
    case trueFalseStorm
    case oddOneOut
    case timelineSprint

    var id: String { rawValue }

    var title: String {
        switch self {
        case .knowledgePathway: return "Knowledge Pathway"
        case .quizTrails: return "Thematic Quiz Trails"
        case .factHunter: return "Fact Hunter Challenge"
        case .trueFalseStorm: return "True or False Storm"
        case .oddOneOut: return "Odd One Out"
        case .timelineSprint: return "Timeline Sprint"
        }
    }
}

struct TriviaQuestion: Identifiable, Codable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let answerIndex: Int
}

struct ActivityResult {
    let activity: ActivityType
    let difficulty: Difficulty
    let stars: Int
    let correctAnswers: Int
    let totalQuestions: Int
    let timeSpent: TimeInterval
    let attempts: Int
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let isUnlocked: Bool
}

struct TimelineEvent: Identifiable, Codable {
    let id = UUID()
    let title: String
    let year: Int
}
