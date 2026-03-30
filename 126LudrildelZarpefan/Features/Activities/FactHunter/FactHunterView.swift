//
//  FactHunterView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct FactHunterView: View {
    @EnvironmentObject private var store: AppProgressStore
    @StateObject private var viewModel: FactHunterViewModel
    @State private var result: ActivityResult?

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: FactHunterViewModel(difficulty: difficulty))
    }

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        Text("Find hidden points and answer each question.")
                            .foregroundStyle(Color.appTextPrimary)
                    }

                    GeometryReader { geometry in
                        ZStack {
                            Canvas { context, size in
                                var outline = Path()
                                outline.addRoundedRect(in: CGRect(origin: .zero, size: size), cornerSize: CGSize(width: 18, height: 18))
                                context.fill(outline, with: .color(.appSurface))

                                for target in viewModel.targets {
                                    let point = CGPoint(x: target.point.x * size.width, y: target.point.y * size.height)
                                    let radius = target.discovered ? 14.0 : (viewModel.difficulty == .easy ? 10.0 : 6.0)
                                    var marker = Path()
                                    marker.addEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
                                    let color: Color = target.discovered ? .appAccent : (viewModel.difficulty == .easy ? .appPrimary.opacity(0.5) : .appPrimary.opacity(0.2))
                                    context.fill(marker, with: .color(color))
                                }
                            }
                            .frame(height: 320)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let normalized = CGPoint(
                                            x: max(0, min(1, value.location.x / max(geometry.size.width, 1))),
                                            y: max(0, min(1, value.location.y / 320))
                                        )
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            viewModel.tap(at: normalized)
                                        }
                                    }
                            )
                        }
                    }
                    .frame(height: 320)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress: \(viewModel.targets.filter(\.discovered).count)/\(viewModel.targets.count)")
                                .foregroundStyle(Color.appTextPrimary)
                            StarsRow(stars: min(viewModel.correct, 3))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Fact Hunter")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: Binding(
            get: { viewModel.selectedQuestion != nil },
            set: { visible in
                if !visible {
                    viewModel.selectedTargetID = nil
                }
            }
        )) {
            if let question = viewModel.selectedQuestion {
                QuestionSheet(question: question) { selected in
                    viewModel.answerSelected(optionIndex: selected)
                }
                .presentationDetents([.medium])
            }
        }
        .onChange(of: viewModel.finished) { finished in
            if finished {
                let resultValue = viewModel.buildResult(
                    attempts: store.attempts(for: .factHunter, difficulty: viewModel.difficulty)
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

private struct QuestionSheet: View {
    let question: TriviaQuestion
    let onSelect: (Int) -> Void

    var body: some View {
        AppScreen {
            VStack(spacing: 14) {
                Text(question.prompt)
                    .foregroundStyle(Color.appTextPrimary)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(option) {
                        onSelect(index)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
