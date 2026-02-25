//
//  NarrativeOnboardingView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 24/02/26.
//
//  HOW TO WIRE IN ContentView — one line change:
//    Before: OnboardingView()
//    After:  NarrativeOnboardingView()
//
//  This file owns the full flow: 3 narrative screens → OnboardingView.
//  Nothing else in the project changes.
//

import SwiftUI

// MARK: - File-level data

private struct PillarInfo {
    let icon: String
    let title: String
    let description: String
    // Same colors as SkyView.pillarColor — visual echo for the judge
    let color: Color
}

private let narrativePillars: [PillarInfo] = [
    PillarInfo(icon: "map",                    title: "The City",
               description: "Navigate it. Own it. Make it yours.",
               color: Color(red: 0.50, green: 0.65, blue: 1.00)),
    PillarInfo(icon: "wrench.and.screwdriver", title: "Adult Mode",
               description: "Bills, cooking, real independence.",
               color: Color(red: 1.00, green: 0.65, blue: 0.45)),
    PillarInfo(icon: "leaf",                   title: "Your Growth",
               description: "Because this isn't just logistics.",
               color: Color(red: 0.50, green: 0.90, blue: 0.65)),
]

// MARK: - Root wrapper

struct NarrativeOnboardingView: View {
    @State private var narrativeDone = false

    var body: some View {
        ZStack {
            if narrativeDone {
                OnboardingView()
                    .transition(.opacity)
            } else {
                NarrativeScreensView {
                    withAnimation(.easeInOut(duration: 0.55)) {
                        narrativeDone = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Screens container

private struct NarrativeScreensView: View {
    let onComplete: () -> Void

    @State private var screen: Int = 0
    @State private var appeared  = false
    @Environment(\.colorScheme) var colorScheme

    private var isDarkSky: Bool { screen == 0 }

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.06, blue: 0.20),
                    Color(red: 0.02, green: 0.02, blue: 0.11)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(isDarkSky ? 1 : 0)
            .animation(.easeInOut(duration: 0.85), value: isDarkSky)

            // Atmosphere (Screens 1-2)
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(isDarkSky ? 0 : 1)
            .animation(.easeInOut(duration: 0.85), value: isDarkSky)

            // Radial accent glow
            RadialGradient(
                colors: [accentGlow.opacity(isDarkSky ? 0.10 : 0.12), Color.clear],
                center: .top, startRadius: 0, endRadius: 520
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.85), value: screen)

            // ── Progress dots ───────────────────────────────────────────────
            VStack {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(dotColor(for: i))
                            .frame(width: i == screen ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: screen)
                    }
                }
                .padding(.top, 64)
                Spacer()
            }
            .animation(.easeInOut(duration: 0.4), value: isDarkSky)

            // ── Active screen ───────────────────────────────────────────────
            Group {
                switch screen {
                case 0:  HookScreen(appeared: appeared)
                case 1:  PillarsScreen(appeared: appeared)
                default: PromiseScreen(appeared: appeared)
                }
            }
            .id(screen)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(x:  55)),
                removal:   .opacity.combined(with: .offset(x: -55))
            ))

            // ── CTA ─────────────────────────────────────────────────────────
            VStack {
                Spacer()
                Button(action: advance) {
                    HStack(spacing: 6) {
                        Text(screen < 2 ? "Continue" : "Meet Fledge")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold) // FIXED
                        Image(systemName: "arrow.right")
                            .font(.system(.body))
                            .fontWeight(.bold) // FIXED
                    }
                    .foregroundColor(isDarkSky
                        ? Color(red: 0.07, green: 0.06, blue: 0.20)
                        : .white
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isDarkSky ? Color.white : Color.accentColor)
                            .shadow(
                                color: isDarkSky
                                    ? Color.white.opacity(0.18)
                                    : Color.accentColor.opacity(0.35),
                                radius: 14, x: 0, y: 6
                            )
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .animation(.easeInOut(duration: 0.35), value: isDarkSky)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                appeared = true
            }
        }
    }

    // MARK: Helpers

    private var accentGlow: Color {
        switch screen {
        case 0:  return Color(red: 0.40, green: 0.50, blue: 1.00)
        default: return Color.accentColor
        }
    }

    private func dotColor(for i: Int) -> Color {
        let isActive = i == screen
        if isDarkSky {
            return isActive ? Color.white : Color.white.opacity(0.22)
        } else {
            return isActive ? Color.accentColor : Color.primary.opacity(0.15)
        }
    }

    private func advance() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        guard screen < 2 else { onComplete(); return }
        appeared = false
        withAnimation(.easeInOut(duration: 0.22)) { screen += 1 }
        withAnimation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.18)) { appeared = true }
    }
}

// MARK: - Starfield Canvas (Screen 0 layer)
// Same technique as SkyView — TimelineView + Canvas for twinkling.

private struct StarfieldCanvas: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for i in 1...60 {
                    let x  = CGFloat((i * 73  + 11) % 100) / 100.0 * size.width
                    let y  = CGFloat((i * 89  + 31) % 100) / 100.0 * size.height
                    let tw = (sin(t * Double(i % 7 + 1) * 0.45 + Double(i) * 0.9) + 1.0) / 2.0
                    let r: CGFloat = i % 9 == 0 ? 1.6 : (i % 4 == 0 ? 1.1 : 0.7)
                    let alpha = 0.04 + 0.14 * tw
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                        with: .color(.white.opacity(alpha))
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Screen 0: The Hook  ------------------------------------------------

private struct HookScreen: View {
    let appeared: Bool

    @State private var revealedWords = 0
    @State private var showSupporting = false
    @State private var glowPulse = false

    // Headline split for controlled line breaks + word-reveal
    private let line1 = ["Moving", "somewhere", "new"]
    private let line2 = ["is", "one", "of", "the", "hardest"]
    private let line3 = ["things", "you'll", "ever", "do."]
    private var allWords: [String] { line1 + line2 + line3 }

    var body: some View {
        ZStack {
            // Star particles
            StarfieldCanvas()
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 1.8), value: appeared)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color(red: 0.40, green: 0.50, blue: 1.00)
                            .opacity(glowPulse ? 0.28 : 0.10))
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)

                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .frame(width: 110, height: 110)
                        .shadow(
                            color: Color(red: 0.40, green: 0.50, blue: 1.00).opacity(0.35),
                            radius: 24, x: 0, y: 8
                        )

                    FledgeLogo(isAppeared: appeared, size: 130)
                }
                .scaleEffect(appeared ? 1.0 : 0.55)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.80, dampingFraction: 0.60).delay(0.05), value: appeared)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }

                Spacer().frame(height: 18)

                // ── App name + tagline ──────────────────────────────────────
                VStack(spacing: 5) {
                    Text("Fledge")
                        .font(.system(.largeTitle, design: .rounded)) // FIXED
                        .fontWeight(.bold) // FIXED
                        .foregroundColor(.white)

                    Text("Your guide to the first 4 weeks on your own.")
                        .font(.system(.headline, design: .rounded)).fontWeight(.medium)
                        .foregroundColor(Color.white.opacity(0.42))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.20), value: appeared)

                Spacer().frame(height: 52)

                // ── Word-by-word headline ───────────────────────────────────
                VStack(spacing: 3) {
                    wordLine(words: line1, globalOffset: 0)
                    wordLine(words: line2, globalOffset: line1.count)
                    wordLine(words: line3, globalOffset: line1.count + line2.count)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 22)

                Text("Most apps don't get that.\nFledge was built for exactly this moment.")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.42))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSupporting ? 1 : 0)
                    .offset(y: showSupporting ? 0 : 10)
                    .animation(.easeOut(duration: 0.55), value: showSupporting)
                    .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
        .onChange(of: appeared) { _, newValue in
            guard newValue else { return }
            // Stagger each word
            for i in 0..<allWords.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55 + Double(i) * 0.088) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                        revealedWords = i + 1
                    }
                }
            }
            // Supporting text after all words are done
            let finishTime = 0.55 + Double(allWords.count) * 0.088 + 0.35
            DispatchQueue.main.asyncAfter(deadline: .now() + finishTime) {
                showSupporting = true
            }
        }
    }

    @ViewBuilder
    private func wordLine(words: [String], globalOffset: Int) -> some View {
        HStack(spacing: 7) {
            ForEach(Array(words.enumerated()), id: \.offset) { localIndex, word in
                let idx = globalOffset + localIndex
                Text(word)
                    .font(.system(.title, design: .rounded)) // FIXED: Removed .title1
                    .fontWeight(.bold) // FIXED
                    .foregroundColor(.white)
                    .opacity(revealedWords > idx ? 1.0 : 0.0)
                    .offset(y: revealedWords > idx ? 0 : 10)
            }
        }
    }
}

// MARK: - Screen 1: The Three Pillars  ---------------------------------------

private struct PillarsScreen: View {
    let appeared: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Three pillars.")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Four weeks. One flight.")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer().frame(height: 2)

                Text("Every mission in Fledge belongs to one of these.")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .animation(.spring(response: 0.55, dampingFraction: 0.80).delay(0.05), value: appeared)

            Spacer().frame(height: 28)

            // Pillar cards
            VStack(spacing: 12) {
                ForEach(narrativePillars.indices, id: \.self) { i in
                    NarrativePillarCard(
                        info: narrativePillars[i],
                        appeared: appeared,
                        delay: 0.14 + Double(i) * 0.13
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
    }
}

private struct NarrativePillarCard: View {
    let info: PillarInfo
    let appeared: Bool
    let delay: Double

    @State private var glowing = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(info.color.opacity(glowing ? 0.22 : 0.13))
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(info.color.opacity(glowing ? 0.38 : 0.22), lineWidth: 1)
                    )
                    .shadow(color: info.color.opacity(glowing ? 0.25 : 0.05), radius: 10)

                Image(systemName: info.icon)
                    .font(.system(size: 22))
                    .foregroundColor(info.color)
            }
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(delay * 0.5), value: glowing)

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(info.title)
                    .font(.system(.title3, design: .rounded)) // FIXED
                    .fontWeight(.bold) // FIXED
                    .foregroundColor(.primary)
                Text(info.description)
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark
                    ? AnyShapeStyle(.regularMaterial)
                    : AnyShapeStyle(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            colorScheme == .dark
                                ? Color.white.opacity(0.07)
                                : Color.black.opacity(0.05),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0 : 0.04),
                    radius: 10, x: 0, y: 4
                )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 24)
        .animation(.spring(response: 0.55, dampingFraction: 0.72).delay(delay), value: appeared)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                glowing = true
            }
        }
    }
}

// MARK: - Screen 2: The Promise  ---------------------------------------------

private struct PromiseScreen: View {
    let appeared: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Headline
            VStack(spacing: 10) {
                Text("One mission a day.")
                    .font(.system(.largeTitle, design: .rounded)) // FIXED
                    .fontWeight(.bold) // FIXED
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("Built around how you actually feel.")
                    .font(.system(.title3, design: .rounded)) // FIXED
                    .fontWeight(.medium) // FIXED
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .animation(.spring(response: 0.55, dampingFraction: 0.80).delay(0.05), value: appeared)
            .padding(.horizontal, 28)

            Spacer().frame(height: 40)

            // Mood chips
            HStack(spacing: 10) {
                ForEach(Array(Mood.allCases.enumerated()), id: \.element.rawValue) { index, mood in
                    NarrativeMoodChip(
                        mood: mood,
                        appeared: appeared,
                        delay: 0.16 + Double(index) * 0.12
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 28)

            Text("Fledge doesn't decide how you feel.\nYou tell it. And everything adjusts.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.55, dampingFraction: 0.80).delay(0.45), value: appeared)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

private struct NarrativeMoodChip: View {
    let mood: Mood
    let appeared: Bool
    let delay: Double

    @State private var pulsing = false
    @Environment(\.colorScheme) var colorScheme

    var chipColor: Color {
        colorScheme == .dark ? mood.color : mood.lightModeColor
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Breathing outer ring
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(chipColor.opacity(pulsing ? 0.35 : 0.10), lineWidth: 1.5)
                    .frame(width: 62, height: 62)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(delay * 0.7), value: pulsing)

                RoundedRectangle(cornerRadius: 14)
                    .fill(chipColor.opacity(pulsing ? 0.18 : 0.10))
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(chipColor.opacity(0.22), lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(delay * 0.7), value: pulsing)

                Image(systemName: mood.icon)
                    .font(.system(size: 22))
                    .foregroundColor(chipColor)
            }
            .frame(width: 64, height: 64)

            Text(mood.rawValue)
                .font(.system(.subheadline, design: .rounded)) // FIXED
                .fontWeight(.semibold) // FIXED
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark
                    ? AnyShapeStyle(.regularMaterial)
                    : AnyShapeStyle(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            colorScheme == .dark
                                ? Color.white.opacity(0.07)
                                : Color.black.opacity(0.05),
                            lineWidth: 1
                        )
                )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.55, dampingFraction: 0.72).delay(delay), value: appeared)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }
}
