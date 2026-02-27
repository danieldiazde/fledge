//
//  MissionRowViews.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

// MARK: - GlassMissionRow

/// A tappable row for a current or past-uncompleted mission.
/// Renders in a locked/dimmed state when `isLocked` is true.
struct GlassMissionRow: View {
    let mission: Mission
    let index: Int
    let isLocked: Bool
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(mission.pillar.color.opacity(isLocked ? 0.06 : 0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(mission.pillar.color.opacity(isLocked ? 0.12 : 0.25), lineWidth: 1)
                    )
                Image(systemName: isLocked ? "lock.fill" : mission.pillar.icon)
                    .font(.system(size: isLocked ? 16 : 18))
                    .foregroundColor(isLocked ? .secondary.opacity(0.4) : mission.pillar.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(mission.title)
                    .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(isLocked ? .secondary : .primary)

                HStack(spacing: 8) {
                    Text(mission.duration)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    if mission.isComplete {
                        Text("Done ✓")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(mission.pillar.color)
                    }
                    if isLocked {
                        Text("Complete \"\(mission.prerequisiteTitle)\" to unlock")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
            }
            Spacer()
            Image(systemName: mission.isComplete ? "checkmark.circle.fill" : (isLocked ? "lock.fill" : "chevron.right"))
                .foregroundColor(mission.isComplete ? mission.pillar.color : (isLocked ? Color.secondary.opacity(0.3) : Color.primary.opacity(0.2)))
                .font(.system(size: mission.isComplete ? 20 : 13, weight: .semibold))
        }
        .padding(16)
        .pillarGlassCard(mission.pillar, cornerRadius: 20, isComplete: mission.isComplete)
        .opacity(mission.isComplete ? 0.55 : (isLocked ? 0.5 : 1.0))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: - UpcomingMissionRow

/// A non-tappable teaser row for missions in future weeks.
struct UpcomingMissionRow: View {
    let mission: Mission
    let index: Int
    let pillarColor: Color
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.04))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
                    )
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary.opacity(0.3))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(mission.title)
                    .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(.secondary.opacity(0.6))
                Text(mission.duration)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.4))
            }

            Spacer()

            Text("Week \(mission.weekNumber)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.primary.opacity(0.04)))
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primary.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: - GlassEmptyStateView

/// Shown when the selected pillar has no missions for the current week.
struct GlassEmptyStateView: View {
    let pillar: Pillar
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: pillar.icon)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(.secondary.opacity(0.4))
            Text("More \(pillar.rawValue) missions coming.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .glassCard(cornerRadius: 20)
    }
}
