//
//  MissionWinViews.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

// MARK: - WinCardView

/// Full-screen overlay shown immediately after the user marks a mission complete.
/// Plays an animated checkmark, particle burst, XP counter, and win message
/// before the user taps through to the `FledgeMomentView`.
struct WinCardView: View {
    let winText: String
    let xpValue: Int
    let pillarColor: Color
    let onContinue: () -> Void

    @State private var checkmarkScale: CGFloat = 0.001
    @State private var particlesBurst = false
    @State private var displayedXP = 0
    @State private var glowPulse = false

    let particleCount = 12
    func particleAngle(_ index: Int) -> Double { Double(index) * (360.0 / Double(particleCount)) }
    func particleRadius(_ index: Int) -> CGFloat { index % 2 == 0 ? 55 : 38 }
    func particleSize(_ index: Int) -> CGFloat { index % 3 == 0 ? 7 : 5 }

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                celebrationGraphic
                xpBadge
                winMessage
                continueButton
            }
            .padding(28)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .strokeBorder(pillarColor.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: pillarColor.opacity(0.15), radius: 24, x: 0, y: -8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation { checkmarkScale = 1.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { particlesBurst = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.85)) { displayedXP = xpValue }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                withAnimation { glowPulse = true }
            }
        }
    }

    private var celebrationGraphic: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                let angle = particleAngle(i) * .pi / 180.0
                let radius = particleRadius(i)
                Circle()
                    .fill(pillarColor.opacity(0.70))
                    .frame(width: particleSize(i), height: particleSize(i))
                    .offset(
                        x: particlesBurst ? cos(angle) * radius : 0,
                        y: particlesBurst ? sin(angle) * radius : 0
                    )
                    .opacity(particlesBurst ? 0 : 1)
                    .animation(
                        .spring(response: 0.55, dampingFraction: 0.62)
                            .delay(0.20 + Double(i) * 0.018),
                        value: particlesBurst
                    )
            }

            Circle()
                .fill(pillarColor.opacity(glowPulse ? 0.22 : 0.07))
                .frame(width: 96, height: 96)
                .blur(radius: 14)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)

            Circle()
                .fill(pillarColor.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay(Circle().strokeBorder(pillarColor.opacity(0.30), lineWidth: 1.5))

            Image(systemName: "checkmark")
                .font(.system(.title2)).fontWeight(.bold)
                .foregroundColor(pillarColor)
                .scaleEffect(checkmarkScale)
                .animation(
                    .spring(response: 0.50, dampingFraction: 0.55).delay(0.10),
                    value: checkmarkScale
                )
        }
        .padding(.top, 10)
    }

    private var xpBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill").font(.system(.subheadline))
            Text("+\(displayedXP) XP earned")
                .font(.system(.subheadline, design: .rounded)).fontWeight(.bold)
                .contentTransition(.numericText(value: Double(displayedXP)))
        }
        .foregroundColor(pillarColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(pillarColor.opacity(0.12)))
        .padding(.top, -4)
    }

    private var winMessage: some View {
        Text(winText)
            .font(.system(.title3, design: .rounded)).fontWeight(.bold)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 8)
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            Text("See your moment →")
                .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 14).fill(pillarColor))
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }
}

// MARK: - FledgeMomentView

/// Full-screen celebration shown after the win card. Features an animated
/// checkmark, expanding concentric rings, a floating starfield, and a
/// mood-reactive background matching the dashboard sky.
struct FledgeMomentView: View {
    let pillarColor: Color
    let pillar: Pillar
    let onDismiss: () -> Void

    @EnvironmentObject var moodManager: MoodManager
    @Environment(\.colorScheme) var colorScheme

    @State private var appeared = false
    @State private var starScale: CGFloat = 0.3
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            momentBackground
            if colorScheme == .dark { starfield }
            momentContent
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.05)) {
                starScale = 1.0
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation { glowPulse = true }
            }
        }
    }

    private var momentBackground: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? moodManager.currentMood.atmosphereColors
                    : moodManager.currentMood.lightModeAtmosphereColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [pillarColor.opacity(colorScheme == .dark ? 0.30 : 0.15), Color.clear],
                center: .center,
                startRadius: 60,
                endRadius: 520
            )
            .ignoresSafeArea()
        }
    }

    private var starfield: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for i in 1...30 {
                    let x  = CGFloat((i * 73  + 11) % 100) / 100.0 * size.width
                    let y  = CGFloat((i * 89  + 31) % 100) / 100.0 * size.height
                    let tw = (sin(t * Double(i % 7 + 1) * 0.45 + Double(i) * 0.9) + 1.0) / 2.0
                    let r: CGFloat = i % 5 == 0 ? 1.6 : (i % 3 == 0 ? 1.1 : 0.7)
                    let alpha = 0.08 + 0.20 * tw
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                        with: .color(.white.opacity(alpha))
                    )
                }
            }
        }
        .ignoresSafeArea()
    }

    private var momentContent: some View {
        VStack(spacing: 0) {
            Spacer()
            celebrationGraphic
            momentText
            Spacer()
            dismissButton
        }
    }

    private var celebrationGraphic: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(pillarColor.opacity(0.18 - Double(i) * 0.05), lineWidth: 1.5)
                    .frame(
                        width: appeared ? CGFloat(80 + i * 65) : 20,
                        height: appeared ? CGFloat(80 + i * 65) : 20
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(Double(i) * 0.1), value: appeared)
            }

            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * .pi / 4
                Circle()
                    .fill(pillarColor.opacity(0.65))
                    .frame(width: 6, height: 6)
                    .offset(
                        x: appeared ? cos(angle) * 72 : 0,
                        y: appeared ? sin(angle) * 72 : 0
                    )
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        .spring(response: 0.55, dampingFraction: 0.52).delay(0.12), value: appeared
                    )
            }

            Circle()
                .fill(pillarColor.opacity(glowPulse ? 0.20 : 0.06))
                .frame(width: 130, height: 130)
                .blur(radius: 24)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [pillarColor.opacity(0.85), pillarColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(starScale)
                .shadow(color: pillarColor.opacity(0.55), radius: 28)
        }
        .frame(height: 220)
    }

    private var momentText: some View {
        VStack(spacing: 14) {
            Text(FledgeMoment.forPillar(pillar))
                .font(.system(.title, design: .rounded)).fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .padding(.top, 42)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)

            Text(pillar.rawValue.uppercased())
                .font(.system(.caption, design: .rounded)).fontWeight(.bold)
                .foregroundColor(pillarColor)
                .tracking(2)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
        }
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Text("Continue →")
                .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 16).fill(pillarColor))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.6), value: appeared)
    }
}
