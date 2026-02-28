//
//  SkyView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

// MARK: - Design tokens

private enum SkyMetrics {
    enum Gradient {
        static let top          = Color(red: 0.12, green: 0.10, blue: 0.28)
        static let mid          = Color(red: 0.05, green: 0.05, blue: 0.18)
        static let base         = Color(red: 0.02, green: 0.02, blue: 0.10)
        static let startRadius: CGFloat = 100
        static let endRadius:   CGFloat = 800
    }
    enum Canvas {
        static let backgroundStarCount  = 50
        static let starSize: CGFloat    = 1.5
        static let breathSpeed          = 2.0
        static let twinkleSpeed         = 0.7
    }
    enum Star {
        static let dimRadius: CGFloat      = 2.5
        static let litRadius: CGFloat      = 4.5
        static let fledgedRadius: CGFloat  = 5.5
        static let baseGlow                = 7.0
        static let fledgedGlow             = 12.0
        static let glowPulse               = 4.0
    }
    enum Line {
        static let dim: CGFloat     = 1.0
        static let lit: CGFloat     = 1.5
        static let fledged: CGFloat = 2.5
    }
    enum Layout {
        static let statusTopPadding: CGFloat  = 64
        static let chipBottomPadding: CGFloat = 96
        static let panelHorizontal: CGFloat   = 24
        static let panelTop: CGFloat          = 40
        static let panelBottom: CGFloat       = 120
    }
}

// MARK: - PillarProgressRow

struct PillarProgressRow: View {
    let pillar: Pillar
    let total: Int
    let done: Int
    let color: Color

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var fraction: CGFloat {
        total > 0 ? CGFloat(done) / CGFloat(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
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
                        .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.6).delay(0.1), value: done)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(pillar.rawValue): \(done) out of \(total) missions completed.")
    }
}

// MARK: - SkyView

struct SkyView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var moodManager: MoodManager
    @State private var appeared = false
    @State private var showCompleted = false
    @ScaledMetric private var largeXPSize: CGFloat = 48
    @ScaledMetric private var moodIconSize: CGFloat = 44
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var allMissions: [Mission]  { MissionData.all }
    private var completedCount: Int     { allMissions.filter { $0.isComplete }.count }
    private var totalCount: Int         { allMissions.count }
    private var isFledged: Bool         { completedCount == totalCount && totalCount > 0 }

    private var statusLine: String {
        if completedCount == 0          { return "Your sky is waiting to be filled." }
        if completedCount == totalCount { return "You fledged. ✦" }
        return "\(completedCount) of \(totalCount) stars lit. Keep going."
    }

    private func missions(for pillar: Pillar) -> [Mission] {
        allMissions.filter { $0.pillar == pillar }
    }

    private func completedCount(for pillar: Pillar) -> Int {
        missions(for: pillar).filter { $0.isComplete }.count
    }

    private func isStarLit(_ index: Int) -> Bool {
        guard index < allMissions.count else { return false }
        return allMissions[index].isComplete
    }

    private func isConnectionLit(_ a: Int, _ b: Int) -> Bool {
        isStarLit(a) && isStarLit(b)
    }

    private func triggerFledgeCelebration() {
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

    // MARK: - Body

    var body: some View {
        ZStack {
            skyGradient
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    skyCanvasSection
                        .containerRelativeFrame(.vertical)
                    journeyStatsPanel
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .easeOut(duration: 0.8).delay(0.2)) { appeared = true }
        }
        .onChange(of: completedCount) { _, newValue in
            if newValue == totalCount && totalCount > 0 { triggerFledgeCelebration() }
        }
        .sensoryFeedback(.success, trigger: isFledged)
    }

    // MARK: - Sky canvas

    private var skyGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                SkyMetrics.Gradient.top,
                SkyMetrics.Gradient.mid,
                SkyMetrics.Gradient.base
            ]),
            center: .top,
            startRadius: SkyMetrics.Gradient.startRadius,
            endRadius:   SkyMetrics.Gradient.endRadius
        )
    }

    private var skyCanvasSection: some View {
        GeometryReader { _ in
            ZStack {
                skyGradient
                constellationCanvas
                    .accessibilityHidden(true)
                VStack(spacing: 0) {
                    statusHeader
                    Spacer()
                    pillarChips
                }
            }
        }
    }

    /// Renders background star field, constellation lines, and mission dots
    /// using a single Canvas pass to avoid per-star view overhead.
    private var constellationCanvas: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time            = timeline.date.timeIntervalSinceReferenceDate
                let breathIntensity = reduceMotion ? 0.5 : (sin(time * SkyMetrics.Canvas.breathSpeed) + 1.0) / 2.0
                let halfStar        = SkyMetrics.Canvas.starSize / 2

                // Background star field
                for i in 1...SkyMetrics.Canvas.backgroundStarCount {
                    let x       = CGFloat((i * 73) % 100) / 100.0 * size.width
                    let y       = CGFloat((i * 91) % 100) / 100.0 * size.height
                    let twinkle = reduceMotion ? 0.5 : (sin(time * Double(i % 5) * SkyMetrics.Canvas.twinkleSpeed) + 1.0) / 2.0
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - halfStar, y: y - halfStar,
                                               width: SkyMetrics.Canvas.starSize,
                                               height: SkyMetrics.Canvas.starSize)),
                        with: .color(Color.white.opacity(0.08 + 0.08 * twinkle))
                    )
                }

                // Constellation lines
                for (a, b) in SkyConstellation.connections {
                    guard a < SkyConstellation.stars.count,
                          b < SkyConstellation.stars.count else { continue }
                    let posA = CGPoint(x: SkyConstellation.stars[a].x * size.width,
                                      y: SkyConstellation.stars[a].y * size.height)
                    let posB = CGPoint(x: SkyConstellation.stars[b].x * size.width,
                                      y: SkyConstellation.stars[b].y * size.height)
                    let lit  = isConnectionLit(a, b)
                    var path = Path()
                    path.move(to: posA)
                    path.addLine(to: posB)
                    context.stroke(
                        path,
                        with: .color(Color.white.opacity(lit ? (isFledged ? 1.0 : 0.4) : 0.12)),
                        lineWidth: lit ? (isFledged ? SkyMetrics.Line.fledged : SkyMetrics.Line.lit)
                                       : SkyMetrics.Line.dim
                    )
                }

                // Mission stars
                for (index, star) in SkyConstellation.stars.enumerated() {
                    let pos    = CGPoint(x: star.x * size.width, y: star.y * size.height)
                    let lit    = isStarLit(index)
                    let pillar = index < allMissions.count ? allMissions[index].pillar : star.pillar
                    let color  = pillar.skyColor

                    let baseGlow   = isFledged ? SkyMetrics.Star.fledgedGlow : SkyMetrics.Star.baseGlow
                    let glowRadius = lit ? baseGlow + SkyMetrics.Star.glowPulse * breathIntensity : 4.0
                    let glowOpacity = lit ? 0.5 + 0.4 * breathIntensity : 0.20
                    let dotRadius: CGFloat = lit
                        ? (isFledged ? SkyMetrics.Star.fledgedRadius : SkyMetrics.Star.litRadius)
                        : SkyMetrics.Star.dimRadius

                    if lit {
                        context.fill(
                            Path(ellipseIn: CGRect(x: pos.x - glowRadius, y: pos.y - glowRadius,
                                                   width: glowRadius * 2, height: glowRadius * 2)),
                            with: .color(color.opacity(isFledged ? 0.5 : 0.35))
                        )
                    }
                    context.fill(
                        Path(ellipseIn: CGRect(x: pos.x - dotRadius, y: pos.y - dotRadius,
                                               width: dotRadius * 2, height: dotRadius * 2)),
                        with: .color(lit ? color : Color.white.opacity(glowOpacity))
                    )
                }
            }
        }
    }

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Week \(arrivalManager.currentWeek) of 4")
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.white.opacity(0.38))
                .textCase(.uppercase)
                .tracking(2)
            Text(statusLine)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SkyMetrics.Layout.panelHorizontal)
        .padding(.top, SkyMetrics.Layout.statusTopPadding)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : (reduceMotion ? 0 : -8))
        .animation(.easeOut(duration: 0.55).delay(0.1), value: appeared)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Week \(arrivalManager.currentWeek) of 4. \(statusLine)")
    }

    private var pillarChips: some View {
        HStack(spacing: 8) {
            ForEach(Pillar.allCases, id: \.self) { pillar in
                let total  = missions(for: pillar).count
                let done   = completedCount(for: pillar)
                let color  = pillar.skyColor
                let isDone = done == total && total > 0

                HStack(spacing: 5) {
                    Circle()
                        .fill(isDone ? color : color.opacity(0.55))
                        .frame(width: 5, height: 5)
                        .accessibilityHidden(true)
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
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(pillar.rawValue): \(done) of \(total)\(isDone ? ", complete" : "")")
            }
        }
        .padding(.bottom, SkyMetrics.Layout.chipBottomPadding)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.55).delay(0.25), value: appeared)
    }

    // MARK: - Journey stats panel

    private var journeyStatsPanel: some View {
        ZStack {
            SkyMetrics.Gradient.base
            VStack(alignment: .leading, spacing: 32) {
                panelTitle
                overallProgressBar
                pillarBreakdown
                xpDisplay
                if completedCount > 0 { completedMissionsEntry }
                moodCard
            }
            .padding(.horizontal, SkyMetrics.Layout.panelHorizontal)
            .padding(.top,        SkyMetrics.Layout.panelTop)
            .padding(.bottom,     SkyMetrics.Layout.panelBottom)
        }
    }

    private var panelTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your Journey")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Week \(arrivalManager.currentWeek) of 4")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color.white.opacity(0.4))
        }
    }

    private var overallProgressBar: some View {
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
                        .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.6), value: completedCount)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 5)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Overall progress: \(completedCount) of \(totalCount) missions complete.")
    }

    private var pillarBreakdown: some View {
        VStack(spacing: 16) {
            ForEach(Pillar.allCases, id: \.self) { pillar in
                PillarProgressRow(
                    pillar: pillar,
                    total: missions(for: pillar).count,
                    done:  completedCount(for: pillar),
                    color: pillar.skyColor
                )
            }
        }
    }

    private var xpDisplay: some View {
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
        .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.4), value: userProfile.totalXP)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(userProfile.totalXP) XP earned.")
    }

    private var completedMissionsEntry: some View {
        Button { showCompleted = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    ForEach(Array(Pillar.allCases.enumerated()), id: \.element) { i, pillar in
                        Circle()
                            .fill(pillar.skyColor)
                            .frame(width: 8, height: 8)
                            .offset(x: CGFloat(i - 1) * 7)
                    }
                }
                .frame(width: 36)
                .accessibilityHidden(true)

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
        .accessibilityLabel("Completed missions. \(completedCount) mission\(completedCount == 1 ? "" : "s") done.")
        .accessibilityHint("Double-tap to view all completed missions.")
        .sheet(isPresented: $showCompleted) {
            CompletedMissionsView()
                .environmentObject(userProfile)
        }
    }

    private var moodCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's mood")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.white.opacity(0.45))
                .textCase(.uppercase)
                .tracking(1.5)

            Button { moodManager.showMoodCheckIn = true } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(moodManager.currentMood.color.opacity(0.20))
                            .frame(width: moodIconSize, height: moodIconSize)
                            .shadow(color: moodManager.currentMood.color.opacity(0.45), radius: 12)
                        Image(systemName: moodManager.currentMood.icon)
                            .font(.system(.title2))
                            .fontWeight(.semibold)
                            .foregroundColor(moodManager.currentMood.color)
                    }

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
            .accessibilityLabel("Current mood: \(moodManager.currentMood.rawValue). \(moodManager.currentMood.subtitle).")
            .accessibilityHint("Double-tap to change your mood.")
            .animation(.easeInOut(duration: 0.4), value: moodManager.currentMood.rawValue)
        }
    }
}
