//
//  SkyView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

struct PillarProgressRow: View {
    let pillar: Pillar
    let total: Int
    let done: Int
    let color: Color
    
    // We compute the fraction safely here
    var fraction: CGFloat {
        total > 0 ? CGFloat(done) / CGFloat(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                    
                    Text(pillar.rawValue)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white.opacity(0.75))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                Spacer()
                Text("\(done)/\(total)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.35))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.8))
                        .frame(width: geo.size.width * fraction, height: 4)
                        .animation(.spring(response: 0.6).delay(0.1), value: done)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 4)
        }
    }
}

struct SkyView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var moodManager: MoodManager
    @State private var appeared = false
    @State private var showCompleted = false
    @ScaledMetric var largeXPSize: CGFloat = 48
    @ScaledMetric var moodIconSize: CGFloat = 44

    var allMissions: [Mission] { MissionData.all }
    var completedCount: Int { allMissions.filter { $0.isComplete }.count }
    var totalCount: Int { allMissions.count }
    var isFledged: Bool { completedCount == totalCount && totalCount > 0 }

    var statusLine: String {
        if completedCount == 0 {
            return "Your sky is waiting to be filled."
        } else if completedCount == totalCount {
            return "You fledged. ✦"
        } else {
            return "\(completedCount) of \(totalCount) stars lit. Keep going."
        }
    }

    // Per-pillar progress
    func missionsFor(_ pillar: Pillar) -> [Mission] {
        allMissions.filter { $0.pillar == pillar }
    }
    func completedFor(_ pillar: Pillar) -> Int {
        missionsFor(pillar).filter { $0.isComplete }.count
    }

    let starLayout: [(x: CGFloat, y: CGFloat, pillar: Pillar, index: Int)] = [
        // --- BODY & SPINE (0-4) ---
        (0.48, 0.41, .adultMode, 0),
        (0.44, 0.47, .adultMode, 1),
        (0.55, 0.44, .adultMode, 2),
        (0.51, 0.51, .adultMode, 3),
        (0.52, 0.57, .adultMode, 4),

        // --- HEAD & NECK (5-9) ---
        (0.49, 0.34, .adultMode, 5),
        (0.45, 0.27, .adultMode, 6),
        (0.41, 0.21, .adultMode, 7),
        (0.50, 0.24, .adultMode, 10),
        (0.39, 0.30, .adultMode, 11),

        // --- TAIL SPINE (10-11) ---
        (0.54, 0.63, .adultMode, 8),
        (0.58, 0.70, .adultMode, 9),

        // --- LEFT WING (12-23) ---
        (0.39, 0.38, .city, 0),
        (0.30, 0.31, .city, 1),
        (0.23, 0.23, .city, 2),
        (0.16, 0.16, .city, 3),
        (0.36, 0.44, .city, 4),
        (0.26, 0.36, .city, 5),
        (0.18, 0.31, .city, 6),
        (0.12, 0.24, .city, 7),
        (0.47, 0.60, .city, 8),
        (0.42, 0.67, .city, 9),
        (0.28, 0.26, .city, 10),
        (0.14, 0.19, .city, 11),

        // --- RIGHT WING (24-35) ---
        (0.59, 0.41, .growth, 0),
        (0.69, 0.37, .growth, 1),
        (0.79, 0.33, .growth, 2),
        (0.89, 0.30, .growth, 3),
        (0.63, 0.47, .growth, 4),
        (0.74, 0.44, .growth, 5),
        (0.84, 0.40, .growth, 6),
        (0.93, 0.37, .growth, 7),
        (0.61, 0.61, .growth, 8),
        (0.68, 0.66, .growth, 9),
        (0.72, 0.33, .growth, 10),
        (0.86, 0.34, .growth, 11)
    ]

    let connections: [(Int, Int)] = [
        (7, 6), (6, 5), (5, 0), (0, 3), (3, 4), (4, 10), (10, 11),
        (6, 8), (5, 9),
        (0, 1), (0, 2), (1, 3), (2, 3),
        (0, 12), (12, 13), (13, 22), (22, 14), (14, 15),
        (13, 16), (14, 17), (22, 18), (18, 19),
        (15, 23), (23, 19),
        (4, 20), (20, 21), (1, 16),
        (0, 24), (24, 25), (25, 34), (34, 26), (26, 27),
        (24, 28), (28, 29),
        (34, 30), (30, 31),
        (27, 35), (35, 31),
        (4, 32), (32, 33)
    ]

    func isStarLit(_ layoutIndex: Int) -> Bool {
        guard layoutIndex < allMissions.count else { return false }
        return allMissions[layoutIndex].isComplete
    }

    func isConnectionLit(_ a: Int, _ b: Int) -> Bool {
        isStarLit(a) && isStarLit(b)
    }

    func pillarColor(_ pillar: Pillar) -> Color {
        switch pillar {
        case .city:      return Color(red: 0.5, green: 0.65, blue: 1.0)
        case .adultMode: return Color(red: 1.0, green: 0.65, blue: 0.45)
        case .growth:    return Color(red: 0.5, green: 0.9, blue: 0.65)
        }
    }

    func triggerFledgeCelebration() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .rigid)
        impact.prepare()
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impact.impactOccurred(intensity: 0.8)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let success = UINotificationFeedbackGenerator()
            success.prepare()
            success.notificationOccurred(.success)
        }
        #endif
    }

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.10, blue: 0.28),
                    Color(red: 0.05, green: 0.05, blue: 0.18),
                    Color(red: 0.02, green: 0.02, blue: 0.10)
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 800
            )
            .ignoresSafeArea()

        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                GeometryReader { geo in
                    ZStack {
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.12, green: 0.10, blue: 0.28),
                                Color(red: 0.05, green: 0.05, blue: 0.18),
                                Color(red: 0.02, green: 0.02, blue: 0.10)
                            ]),
                            center: .top,
                            startRadius: 100,
                            endRadius: 800
                        )

                        TimelineView(.animation) { timeline in
                            Canvas { context, size in
                                let time = timeline.date.timeIntervalSinceReferenceDate
                                let breathIntensity = (sin(time * 2.0) + 1.0) / 2.0

                                for i in 1...50 {
                                    let bgX = CGFloat((i * 73) % 100) / 100.0 * size.width
                                    let bgY = CGFloat((i * 91) % 100) / 100.0 * size.height
                                    let twinkle = (sin(time * Double(i % 5) * 0.7) + 1.0) / 2.0
                                    context.fill(
                                        Path(ellipseIn: CGRect(x: bgX - 0.75, y: bgY - 0.75, width: 1.5, height: 1.5)),
                                        with: .color(Color.white.opacity(0.08 + (0.08 * twinkle)))
                                    )
                                }

                                // Connections
                                for (a, b) in connections {
                                    guard a < starLayout.count, b < starLayout.count else { continue }
                                    let posA = CGPoint(x: starLayout[a].x * size.width, y: starLayout[a].y * size.height)
                                    let posB = CGPoint(x: starLayout[b].x * size.width, y: starLayout[b].y * size.height)
                                    let lit = isConnectionLit(a, b)
                                    var path = Path()
                                    path.move(to: posA)
                                    path.addLine(to: posB)
                                    context.stroke(
                                        path,
                                        with: .color(Color.white.opacity(lit ? (isFledged ? 1.0 : 0.4) : 0.12)),
                                        lineWidth: lit ? (isFledged ? 2.5 : 1.5) : 1.0
                                    )
                                }

                                // Stars
                                for (layoutIndex, star) in starLayout.enumerated() {
                                    let pos = CGPoint(x: star.x * size.width, y: star.y * size.height)
                                    let lit = isStarLit(layoutIndex)
                                    let actualPillar = layoutIndex < allMissions.count ? allMissions[layoutIndex].pillar : star.pillar
                                    let color = pillarColor(actualPillar)
                                    let baseGlowRadius = isFledged ? 12.0 : 7.0
                                    let glowRadius = lit ? (baseGlowRadius + (4.0 * breathIntensity)) : 4.0
                                    let glowOpacity = lit ? (0.5 + (0.4 * breathIntensity)) : 0.20
                                    let dotRadius: CGFloat = lit ? (isFledged ? 5.5 : 4.5) : 2.5

                                    if lit {
                                        context.fill(
                                            Path(ellipseIn: CGRect(
                                                x: pos.x - glowRadius, y: pos.y - glowRadius,
                                                width: glowRadius * 2, height: glowRadius * 2
                                            )),
                                            with: .color(color.opacity(isFledged ? 0.5 : 0.35))
                                        )
                                    }
                                    context.fill(
                                        Path(ellipseIn: CGRect(
                                            x: pos.x - dotRadius, y: pos.y - dotRadius,
                                            width: dotRadius * 2, height: dotRadius * 2
                                        )),
                                        with: .color(lit ? color : Color.white.opacity(glowOpacity))
                                    )
                                }
                            }
                        }

                        VStack(spacing: 0) {

                            // ── Top: week context + status ──────────────────
                            VStack(alignment: .leading, spacing: 6) {

                                // Week eyebrow
                                Text("Week \(arrivalManager.currentWeek) of 4")
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white.opacity(0.38))
                                    .textCase(.uppercase)
                                    .tracking(2)

                                // Status — the one thing that matters up here
                                Text(statusLine)
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 64)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : -8)
                            .animation(.easeOut(duration: 0.55).delay(0.1), value: appeared)

                            Spacer()

                            // ── Bottom: pillar chips ────────────────────────
                            HStack(spacing: 8) {
                                ForEach(Pillar.allCases, id: \.self) { pillar in
                                    let total = missionsFor(pillar).count
                                    let done  = completedFor(pillar)
                                    let color = pillarColor(pillar)
                                    let isDone = done == total && total > 0

                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(isDone ? color : color.opacity(0.55))
                                            .frame(width: 5, height: 5)
                                        Text(pillar.rawValue)
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.white.opacity(isDone ? 0.85 : 0.50))
                                        Text("\(done)/\(total)")
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(Color.white.opacity(isDone ? 0.65 : 0.28))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(color.opacity(isDone ? 0.18 : 0.08))
                                            .overlay(
                                                Capsule()
                                                    .strokeBorder(color.opacity(isDone ? 0.35 : 0.15), lineWidth: 1)
                                            )
                                    )
                                    .animation(.easeInOut(duration: 0.4), value: isDone)
                                }
                            }
                            .padding(.bottom, 96)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.55).delay(0.25), value: appeared)
                        }
                    }
                }
                .containerRelativeFrame(.vertical)

                // MARK: - Journey Stats Panel
                ZStack {
                    // Dark background continuing from sky
                    Color(red: 0.02, green: 0.02, blue: 0.10)

                    VStack(alignment: .leading, spacing: 32) {

                        // Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Journey")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Week \(arrivalManager.currentWeek) of 4")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.4))
                        }

                        // Overall progress
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Overall")
                                    .font(.system(.callout, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.5))
                                    .textCase(.uppercase)
                                    .tracking(1)
                                Spacer()
                                Text("\(completedCount) of \(totalCount)")
                                    .font(.system(.callout, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.4))
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 5)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.5))
                                        .frame(
                                            width: totalCount > 0
                                                ? geo.size.width * CGFloat(completedCount) / CGFloat(totalCount)
                                                : 0,
                                            height: 5
                                        )
                                        .animation(.spring(response: 0.6), value: completedCount)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 5)
                        }

                        // Per-pillar breakdown
                        VStack(spacing: 16) {
                            ForEach(Pillar.allCases, id: \.self) { pillar in
                                PillarProgressRow(
                                    pillar: pillar,
                                    total: missionsFor(pillar).count,
                                    done: completedFor(pillar),
                                    color: pillarColor(pillar)
                                )
                            }
                        }

                        // XP total — large
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(userProfile.totalXP)")
                                .font(.system(size: largeXPSize, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .contentTransition(.numericText())
                            Text("XP earned")
                                .font(.system(.title3, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.4))
                                .padding(.bottom, 6)
                        }
                        .animation(.spring(response: 0.4), value: userProfile.totalXP)

                        // ── Completed missions entry ────────────────────────
                        if completedCount > 0 {
                            Button {
                                showCompleted = true
                            } label: {
                                HStack(spacing: 14) {
                                    // Icon cluster — stacked colored dots
                                    ZStack {
                                        ForEach(Array(Pillar.allCases.enumerated()), id: \.element) { i, pillar in
                                            Circle()
                                                .fill(pillarColor(pillar))
                                                .frame(width: 8, height: 8)
                                                .offset(x: CGFloat(i - 1) * 7)
                                        }
                                    }
                                    .frame(width: 36)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Completed missions")
                                            .font(.system(.callout, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Text("\(completedCount) mission\(completedCount == 1 ? "" : "s") done")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.40))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(.subheadline))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.white.opacity(0.25))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.06))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            .sheet(isPresented: $showCompleted) {
                                CompletedMissionsView()
                                    .environmentObject(userProfile)
                            }
                        }

                        // Today's mood — full card, not a whisper
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's mood")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.45))
                                .textCase(.uppercase)
                                .tracking(1.5)

                            Button {
                                moodManager.showMoodCheckIn = true
                            } label: {
                                HStack(spacing: 16) {

                                    // Icon — large, glowing
                                    ZStack {
                                        Circle()
                                            .fill(moodManager.currentMood.color.opacity(0.20))
                                            .frame(width: moodIconSize, height: moodIconSize)
                                            .shadow(color: moodManager.currentMood.color.opacity(0.45), radius: 12, x: 0, y: 0)
                                        Image(systemName: moodManager.currentMood.icon)
                                            .font(.system(.title2))
                                            .fontWeight(.semibold)
                                            .foregroundColor(moodManager.currentMood.color)
                                    }

                                    // Text
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(moodManager.currentMood.rawValue)
                                            .font(.system(.title3, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text(moodManager.currentMood.subtitle)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.50))
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    // Change affordance
                                    VStack(spacing: 3) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(.callout))
                                            .fontWeight(.semibold)
                                            .foregroundColor(moodManager.currentMood.color.opacity(0.80))
                                        Text("Change")
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(moodManager.currentMood.color.opacity(0.60))
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(moodManager.currentMood.color.opacity(0.13))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(moodManager.currentMood.color.opacity(0.35), lineWidth: 1)
                                        )
                                        .shadow(color: moodManager.currentMood.color.opacity(0.20), radius: 16, x: 0, y: 6)
                                }
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.4), value: moodManager.currentMood.rawValue)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 120)
                }
            }
        } // ScrollView
        .ignoresSafeArea()
        } // outer ZStack
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appeared = true
            }
        }
        .onChange(of: completedCount) { oldValue, newValue in
            if newValue == totalCount && totalCount > 0 {
                triggerFledgeCelebration()
            }
        }
        .sensoryFeedback(.success, trigger: isFledged)
    }
}
