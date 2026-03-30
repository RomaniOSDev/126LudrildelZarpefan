//
//  QuizTrailsView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI
import Combine

struct QuizTrailsView: View {
    @EnvironmentObject private var store: AppProgressStore
    @StateObject private var viewModel: QuizTrailsViewModel
    @State private var result: ActivityResult?
    @AppStorage("quizTrailsBestCorrect") private var bestCorrect = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: QuizTrailsViewModel(difficulty: difficulty))
    }

    var body: some View {
        AppScreen {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time Left: \(viewModel.timeLeft)s")
                                    .foregroundStyle(Color.appTextPrimary)
                                ProgressView(value: Double(viewModel.timeLeft), total: Double(max(viewModel.initialTime, 1)))
                                    .tint(.appAccent)
                                Text("Best Correct: \(bestCorrect)")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }

                        if let question = viewModel.currentQuestion, !viewModel.finished {
                            SurfaceCard {
                                Text(question.prompt)
                                    .font(.title3.bold())
                                    .foregroundStyle(Color.appTextPrimary)
                            }

                            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                Button(option) {
                                    viewModel.answer(index)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .frame(width: max(geometry.size.width - 32, 44))
                            }
                        } else {
                            SurfaceCard {
                                Text("Trail complete. Preparing results...")
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                        }

                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Answered")
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                                ForEach(viewModel.answeredTitles.suffix(6), id: \.self) { line in
                                    Text(line)
                                        .font(.footnote)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle("Quiz Trails")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            viewModel.tick()
            if viewModel.finished && result == nil {
                let resultValue = viewModel.buildResult(
                    attempts: store.attempts(for: .quizTrails, difficulty: viewModel.difficulty)
                )
                bestCorrect = max(bestCorrect, resultValue.correctAnswers)
                store.record(result: resultValue)
                result = resultValue
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { result != nil },
            set: { if !$0 { result = nil } }
        )) {
            if let result {
                ResultView(result: result)
            }
        }
    }
}
