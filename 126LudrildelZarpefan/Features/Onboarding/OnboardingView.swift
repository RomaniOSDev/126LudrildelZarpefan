//
//  OnboardingView.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0
    @State private var animate = false

    private let slides: [OnboardingItem] = [
        OnboardingItem(
            title: "Discover Fresh Challenges",
            subtitle: "Play short trivia sessions across themes and find the modes that match your pace.",
            highlights: ["Smart progression", "Multiple game modes", "Quick daily sessions"]
        ),
        OnboardingItem(
            title: "Earn Up To 3 Stars",
            subtitle: "Each run is scored by accuracy and speed. Replay levels to improve your best result.",
            highlights: ["Accuracy matters", "Speed bonus", "Clear performance feedback"]
        ),
        OnboardingItem(
            title: "Track Growth",
            subtitle: "See your stats, unlock achievements, and focus on weak spots with balance insights.",
            highlights: ["Progress analytics", "Achievement goals", "Reset anytime"]
        )
    ]

    var body: some View {
        AppScreen {
            VStack(spacing: 18) {
                topBar

                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, item in
                        OnboardingSlide(item: item, index: index, animate: animate)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 520)
                .animation(.easeInOut(duration: 0.25), value: page)

                pageDots

                Button(page == slides.count - 1 ? "Start Playing" : "Continue") {
                    if page < slides.count - 1 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            page += 1
                        }
                    } else {
                        onFinish()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("Welcome")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            if page < slides.count - 1 {
                Button("Skip") {
                    onFinish()
                }
                .foregroundStyle(Color.appTextSecondary)
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.appAccent : Color.appTextSecondary.opacity(0.45))
                    .frame(width: index == page ? 26 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: page)
    }
}

private struct OnboardingItem {
    let title: String
    let subtitle: String
    let highlights: [String]
}

private struct OnboardingSlide: View {
    let item: OnboardingItem
    let index: Int
    let animate: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Canvas { context, size in
                    let w = size.width
                    let h = size.height
                    let center = CGPoint(x: w * 0.5, y: h * 0.5)
                    let radius = min(w, h) * 0.28

                    var ring = Path()
                    ring.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
                    context.stroke(ring, with: .color(.appPrimary.opacity(0.85)), lineWidth: 5)

                    for i in 0..<8 {
                        let angle = CGFloat(i) * (.pi / 4) + (animate ? 0.35 : -0.35) + CGFloat(index) * 0.28
                        let orbit = radius * (0.72 + CGFloat(i % 2) * 0.2)
                        let point = CGPoint(x: center.x + cos(angle) * orbit, y: center.y + sin(angle) * orbit)
                        var node = Path()
                        let nodeSize = CGFloat(i % 2 == 0 ? 14 : 10)
                        node.addEllipse(in: CGRect(x: point.x - nodeSize * 0.5, y: point.y - nodeSize * 0.5, width: nodeSize, height: nodeSize))
                        context.fill(node, with: .color(i % 2 == 0 ? .appAccent : .appTextPrimary.opacity(0.85)))

                        var link = Path()
                        link.move(to: center)
                        link.addLine(to: point)
                        context.stroke(link, with: .color(.appAccent.opacity(0.32)), lineWidth: 1.2)
                    }
                }
                .frame(height: 230)
                .shadow(color: .appAccent.opacity(0.18), radius: 14, x: 0, y: 8)

                Text(item.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                Text(item.subtitle)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                VStack(spacing: 8) {
                    ForEach(item.highlights, id: \.self) { highlight in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color.appAccent)
                            Text(highlight)
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(Color.appSurface.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}
