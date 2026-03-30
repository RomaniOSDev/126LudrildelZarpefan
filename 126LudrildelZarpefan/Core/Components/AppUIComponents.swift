//
//  AppUIComponents.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 30.03.2026.
//

import SwiftUI

struct SurfaceCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.appSurface.opacity(0.96), Color.appSurface.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.55), Color.appTextPrimary.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.appBackground.opacity(0.35), radius: 16, x: 0, y: 10)
            .shadow(color: Color.appAccent.opacity(0.12), radius: 8, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 14)
            .frame(minWidth: 44, minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: configuration.isPressed
                        ? [Color.appAccent.opacity(0.95), Color.appPrimary.opacity(0.90)]
                        : [Color.appPrimary, Color.appAccent.opacity(0.86)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appTextPrimary.opacity(0.14), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.appBackground.opacity(configuration.isPressed ? 0.18 : 0.30), radius: configuration.isPressed ? 6 : 12, x: 0, y: configuration.isPressed ? 3 : 8)
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: configuration.isPressed)
    }
}

struct AppScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.appSurface.opacity(0.74), Color.appBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [Color.appAccent.opacity(0.25), Color.clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 420
            )
            .ignoresSafeArea()
            content
        }
    }
}
