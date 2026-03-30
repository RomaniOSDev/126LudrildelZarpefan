//
//  TimelineSprintView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct TimelineSprintView: View {
    @EnvironmentObject private var store: AppProgressStore
    @StateObject private var viewModel: TimelineSprintViewModel
    @State private var result: ActivityResult?
    @State private var sweep: CGFloat = 0

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: TimelineSprintViewModel(difficulty: difficulty))
    }

    var body: some View {
        AppScreen {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        Canvas { context, size in
                            let y = size.height * 0.5
                            var line = Path()
                            line.move(to: CGPoint(x: 18, y: y))
                            line.addLine(to: CGPoint(x: size.width - 18, y: y))
                            context.stroke(line, with: .color(.appPrimary), lineWidth: 4)

                            for idx in 0..<5 {
                                let x = 18 + CGFloat(idx) * ((size.width - 36) / 4)
                                var tick = Path()
                                tick.addEllipse(in: CGRect(x: x - 8, y: y - 8, width: 16, height: 16))
                                context.fill(tick, with: .color(.appAccent))
                            }

                            var runner = Path()
                            let rx = 18 + sweep * (size.width - 36)
                            runner.addEllipse(in: CGRect(x: rx - 10, y: y - 22, width: 20, height: 20))
                            context.fill(runner, with: .color(.appTextPrimary))
                        }
                        .frame(height: 120)
                    }

                    SurfaceCard {
                        Text("Drag events into chronological order.")
                            .foregroundStyle(Color.appTextPrimary)
                    }

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(viewModel.arranged.enumerated()), id: \.element.id) { index, event in
                                HStack {
                                    Text("\(index + 1).")
                                        .foregroundStyle(Color.appTextSecondary)
                                    Text(event.title)
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                    if viewModel.submitted {
                                        Text("\(event.year)")
                                            .foregroundStyle(Color.appAccent)
                                    }
                                }
                                .frame(minHeight: 44)
                            }
                        }
                    }

                    if !viewModel.submitted {
                        Button("Submit Order") {
                            viewModel.submit()
                            let ready = viewModel.buildResult(
                                attempts: store.attempts(for: .timelineSprint, difficulty: viewModel.difficulty)
                            )
                            store.record(result: ready)
                            result = ready
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    Text("Use Edit below to reorder.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)

                    List {
                        ForEach(Array(viewModel.arranged.enumerated()), id: \.element.id) { _, event in
                            Text(event.title)
                                .foregroundStyle(Color.appTextPrimary)
                                .listRowBackground(Color.appSurface)
                        }
                        .onMove(perform: viewModel.move)
                    }
                    .frame(height: 280)
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, .constant(.active))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Timeline Sprint")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                sweep = 1
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
