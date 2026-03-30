//
//  TrueFalseStormView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI
import Combine

struct TrueFalseStormView: View {
    @EnvironmentObject private var store: AppProgressStore
    @StateObject private var viewModel: TrueFalseStormViewModel
    @State private var result: ActivityResult?
    @State private var pulse: CGFloat = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: TrueFalseStormViewModel(difficulty: difficulty))
    }

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        Canvas { context, size in
                            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                            let base = min(size.width, size.height) * 0.30
                            for i in 0..<6 {
                                let angle = CGFloat(i) * .pi / 3 + pulse
                                let point = CGPoint(x: center.x + cos(angle) * base, y: center.y + sin(angle) * base)
                                var dot = Path()
                                dot.addEllipse(in: CGRect(x: point.x - 9, y: point.y - 9, width: 18, height: 18))
                                context.fill(dot, with: .color(.appAccent.opacity(0.85)))
                            }
                            var ring = Path()
                            ring.addEllipse(in: CGRect(x: center.x - base * 0.55, y: center.y - base * 0.55, width: base * 1.1, height: base * 1.1))
                            context.stroke(ring, with: .color(.appPrimary), lineWidth: 5)
                        }
                        .frame(height: 120)
                    }

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time Left: \(viewModel.timeLeft)s")
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Question \(min(viewModel.index + 1, viewModel.questions.count))/\(viewModel.questions.count)")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    if let question = viewModel.currentQuestion, !viewModel.finished {
                        SurfaceCard {
                            Text(question.prompt)
                                .font(.title3.bold())
                                .foregroundStyle(Color.appTextPrimary)
                        }

                        Button("True") {
                            viewModel.answerTrueFalse(true)
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("False") {
                            viewModel.answerTrueFalse(false)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    } else {
                        SurfaceCard {
                            Text("Storm complete. Opening results...")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("True or False")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            viewModel.tick()
            if viewModel.finished && result == nil {
                let ready = viewModel.buildResult(
                    attempts: store.attempts(for: .trueFalseStorm, difficulty: viewModel.difficulty)
                )
                store.record(result: ready)
                result = ready
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                pulse = .pi * 2
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
