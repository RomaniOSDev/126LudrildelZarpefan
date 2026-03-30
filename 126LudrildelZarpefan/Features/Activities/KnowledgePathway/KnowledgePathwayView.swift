//
//  KnowledgePathwayView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct KnowledgePathwayView: View {
    @EnvironmentObject private var store: AppProgressStore
    @StateObject private var viewModel: KnowledgePathwayViewModel
    @State private var result: ActivityResult?

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: KnowledgePathwayViewModel(difficulty: difficulty))
    }

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Step \(viewModel.index + 1) of \(viewModel.questions.count)")
                                .foregroundStyle(Color.appTextSecondary)
                            Text(viewModel.currentQuestion.prompt)
                                .font(.title3.bold())
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }

                    ForEach(Array(viewModel.currentQuestion.options.enumerated()), id: \.offset) { optionIndex, option in
                        Button(option) {
                            viewModel.choose(optionIndex)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(viewModel.selectedIndex == optionIndex ? Color.appAccent : Color.clear, lineWidth: 2)
                        )
                    }

                    Button(viewModel.index + 1 == viewModel.questions.count ? "Finish Path" : "Next Step") {
                        viewModel.next()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.selectedIndex == nil)
                    .opacity(viewModel.selectedIndex == nil ? 0.6 : 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Knowledge Pathway")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isCompleted) { done in
            if done {
                let resultValue = viewModel.buildResult(
                    attempts: store.attempts(for: .knowledgePathway, difficulty: viewModel.difficulty)
                )
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
