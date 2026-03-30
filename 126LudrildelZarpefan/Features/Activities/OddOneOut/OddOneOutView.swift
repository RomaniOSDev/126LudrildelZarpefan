//
//  OddOneOutView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct OddOneOutView: View {
    @EnvironmentObject private var store: AppProgressStore
    @StateObject private var viewModel: OddOneOutViewModel
    @State private var result: ActivityResult?
    @State private var wobble = false

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: OddOneOutViewModel(difficulty: difficulty))
    }

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        Canvas { context, size in
                            let w = size.width
                            let h = size.height
                            let positions: [CGPoint] = [
                                CGPoint(x: w * 0.25, y: h * 0.30),
                                CGPoint(x: w * 0.50, y: h * 0.30),
                                CGPoint(x: w * 0.75, y: h * 0.30),
                                CGPoint(x: w * 0.50, y: h * 0.70)
                            ]

                            for idx in 0..<positions.count {
                                let p = positions[idx]
                                var shape = Path()
                                if idx == 3 {
                                    shape.addRoundedRect(
                                        in: CGRect(x: p.x - 16, y: p.y - 16, width: 32, height: 32),
                                        cornerSize: CGSize(width: 8, height: 8)
                                    )
                                } else {
                                    shape.addEllipse(in: CGRect(x: p.x - 14, y: p.y - 14, width: 28, height: 28))
                                }
                                context.fill(shape, with: .color(idx == 3 ? .appAccent : .appPrimary))
                            }
                        }
                        .frame(height: 120)
                        .rotationEffect(.degrees(wobble ? 2.5 : -2.5))
                    }

                    SurfaceCard {
                        Text("Round \(min(viewModel.index + 1, viewModel.rounds.count))/\(viewModel.rounds.count)")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    if let round = viewModel.currentRound, !viewModel.finished {
                        SurfaceCard {
                            Text(round.prompt)
                                .font(.title3.bold())
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        ForEach(Array(round.options.enumerated()), id: \.offset) { index, option in
                            Button(option) {
                                viewModel.answer(index)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    } else {
                        SurfaceCard {
                            Text("Challenge complete. Opening results...")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Odd One Out")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
                wobble.toggle()
            }
        }
        .onChange(of: viewModel.finished) { done in
            if done && result == nil {
                let ready = viewModel.buildResult(
                    attempts: store.attempts(for: .oddOneOut, difficulty: viewModel.difficulty)
                )
                store.record(result: ready)
                result = ready
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
