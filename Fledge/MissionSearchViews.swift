//
//  MissionSearchViews.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

// MARK: - SearchMissionRow

/// A search-result row; unlike `GlassMissionRow` it also shows pillar and week badges
/// so the user can orient the result within the full mission structure.
struct SearchMissionRow: View {
    let mission: Mission
    let index: Int
    let isLocked: Bool
    let currentWeek: Int

    @State private var appeared = false
    @Environment(\.colorScheme) var colorScheme

    var isCurrentWeek: Bool { mission.weekNumber == currentWeek }

    var pillarColor: Color {
        colorScheme == .dark ? mission.pillar.color : mission.pillar.lightModeColor
    }

    private var rowAccessibilityLabel: String {
        let weekDesc = isCurrentWeek ? "this week" : "week \(mission.weekNumber)"
        if isLocked {
            return "\(mission.pillar.rawValue) mission, \(weekDesc): \(mission.title). Locked."
        } else if mission.isComplete {
            return "\(mission.pillar.rawValue) mission, \(weekDesc): \(mission.title). Completed."
        } else {
            return "\(mission.pillar.rawValue) mission, \(weekDesc): \(mission.title). \(mission.duration)."
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(pillarColor.opacity(isLocked ? 0.06 : 0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(pillarColor.opacity(isLocked ? 0.12 : 0.25), lineWidth: 1)
                    )
                Image(systemName: isLocked ? "lock.fill" : mission.pillar.icon)
                    .font(.system(isLocked ? .title3 : .title2))
                    .foregroundColor(isLocked ? .secondary.opacity(0.4) : pillarColor)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(mission.title)
                    .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(isLocked ? .secondary : .primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(mission.pillar.rawValue)
                        .font(.system(.caption2, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(pillarColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(pillarColor.opacity(0.12)))

                    Text(isCurrentWeek ? "This week" : "Week \(mission.weekNumber)")
                        .font(.system(.caption2, design: .rounded)).fontWeight(.semibold)
                        .foregroundColor(isCurrentWeek ? Color.accentColor : .secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(isCurrentWeek
                                ? Color.accentColor.opacity(0.10)
                                : Color.primary.opacity(0.06)
                            )
                        )

                    Text(mission.duration)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: mission.isComplete ? "checkmark.circle.fill" : (isLocked ? "lock.fill" : "chevron.right"))
                .foregroundColor(mission.isComplete ? pillarColor : (isLocked ? .secondary.opacity(0.3) : .primary.opacity(0.2)))
                .font(.system(mission.isComplete ? .title2 : .callout)).fontWeight(.semibold)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark
                      ? AnyShapeStyle(.regularMaterial)
                      : AnyShapeStyle(Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            colorScheme == .dark
                                ? Color.white.opacity(0.07)
                                : Color.black.opacity(0.04),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0 : 0.04),
                    radius: 8, x: 0, y: 3
                )
        }
        .opacity(mission.isComplete ? 0.55 : (isLocked ? 0.5 : 1.0))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.80).delay(Double(index) * 0.04)) {
                appeared = true
            }
        }
    }
}

// MARK: - ActivePillarPill

/// Compact banner shown in the header while search is active; replaces the full
/// `MorphingPillarSwitcher` and indicates which pillar context is still selected.
struct ActivePillarPill: View {
    let pillar: Pillar
    let colorScheme: ColorScheme
    let onDismiss: () -> Void

    var effectiveColor: Color {
        colorScheme == .dark ? pillar.color : pillar.lightModeColor
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: pillar.icon)
                .font(.system(.callout)).fontWeight(.semibold)
                .foregroundColor(effectiveColor)
            Text("Searching all missions")
                .font(.system(.callout, design: .rounded)).fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Searching all missions. \(pillar.rawValue) pillar selected.")
    }
}

// MARK: - Search empty states

/// Shown when the keyboard is up but no query has been typed yet.
struct SearchEmptyPrompt: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(.title))
                .foregroundColor(.secondary.opacity(0.35))
                .accessibilityHidden(true)
            Text("Type to search all missions")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.secondary.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Type to search all missions.")
    }
}

/// Shown when a query returns no matching missions.
struct SearchNoResults: View {
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(.title))
                .foregroundColor(.secondary.opacity(0.35))
            VStack(spacing: 4) {
                Text("No missions found")
                    .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text("Nothing matching \"\(query)\"")
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("No missions found for \"\(query)\".")
    }
}
