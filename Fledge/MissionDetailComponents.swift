//
//  MissionDetailComponents.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

// MARK: - Section style

/// Controls the visual treatment of a `MoodAdaptiveSection`.
enum SectionStyle { case briefing, standard }

// MARK: - MissionHeroView

/// Top of the detail screen: pillar pill, large mission title, and duration.
struct MissionHeroView: View {
    let mission: Mission
    let pillarColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: mission.pillar.icon)
                    .font(.system(.caption2)).fontWeight(.semibold)
                Text(mission.pillar.rawValue)
                    .font(.system(.caption2, design: .rounded)).fontWeight(.semibold)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            .foregroundColor(pillarColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(pillarColor.opacity(0.12)))

            Text(mission.title)
                .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 4) {
                Image(systemName: "clock").font(.system(.caption))
                Text(mission.duration).font(.system(.subheadline, design: .rounded))
            }
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(mission.pillar.rawValue) mission: \(mission.title). Duration: \(mission.duration).")
    }
}

// MARK: - MoodAdaptiveSection

/// A text section whose content changes with `activeMood`. Supports two visual
/// styles: `.briefing` (blockquote with accent bar) and `.standard` (pull quote).
struct MoodAdaptiveSection: View {
    let label: String
    let icon: String
    let content: String
    let color: Color
    let style: SectionStyle
    let appeared: Bool
    let delay: Double

    @EnvironmentObject var moodManager: MoodManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group {
            if style == .briefing {
                HStack(alignment: .top, spacing: 16) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 3)
                        .padding(.vertical, 2)

                    Text(content)
                        .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)

            } else {
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: "quote.opening")
                        .font(.system(.title2)).fontWeight(.bold)
                        .foregroundColor(color.opacity(0.35))

                    Text(content)
                        .font(.system(.callout, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : (reduceMotion ? 0 : 12))
        .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

// MARK: - ObjectiveView

/// A single-line mission objective with a scope icon.
struct ObjectiveView: View {
    let objective: String
    let pillarColor: Color
    let appeared: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "scope")
                .font(.system(.subheadline)).fontWeight(.semibold)
                .foregroundColor(pillarColor)
                .padding(.top, 1)

            Text(objective)
                .font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appeared)
    }
}

// MARK: - RevealMoveButton

/// Full-width button that reveals the steps section when tapped.
struct RevealMoveButton: View {
    let pillarColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ready to move?")
                        .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("See the steps for this mission")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(.title))
                    .foregroundColor(pillarColor)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(pillarColor.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(pillarColor.opacity(0.18), lineWidth: 1)
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Double-tap to reveal the steps for this mission.")
    }
}

// MARK: - MissionBottomBar

/// Sticky bar at the bottom of the screen showing step progress and the
/// "Mission Complete" button. Only visible once the steps section is revealed.
struct MissionBottomBar: View {
    let progressFraction: Double
    let completedCount: Int
    let totalCount: Int
    let allStepsComplete: Bool
    let pillarColor: Color
    let xpValue: Int
    let onComplete: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color("AtmosphereTop").opacity(0), Color("AtmosphereTop")],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").font(.system(.caption2))
                    Text("\(xpValue) XP on completion")
                        .font(.system(.caption, design: .rounded)).fontWeight(.semibold)
                }
                .foregroundColor(pillarColor.opacity(0.7))
                .accessibilityHidden(true)

                Button(action: onComplete) {
                    HStack(spacing: 10) {
                        Image(systemName: allStepsComplete ? "checkmark" : "lock.fill")
                            .font(.system(.headline)).fontWeight(.bold)
                        Text(allStepsComplete ? "Mission Complete" : "Complete all steps first")
                            .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                    }
                    .foregroundColor(allStepsComplete ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(allStepsComplete
                                ? AnyShapeStyle(pillarColor)
                                : AnyShapeStyle(Color.primary.opacity(0.06))
                            )
                    }
                }
                .disabled(!allStepsComplete)
                .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.4), value: allStepsComplete)
                .accessibilityLabel(allStepsComplete ? "Mission complete" : "Complete all steps to unlock this mission.")
                .accessibilityHint(allStepsComplete ? "Double-tap to earn \(xpValue) XP and mark this mission as complete." : "")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .background(Color("AtmosphereTop"))
        }
    }
}

// MARK: - CompletedBadge

/// A persistent banner shown at the bottom of the screen for already-completed missions.
struct CompletedBadge: View {
    let pillarColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(pillarColor)
                .font(.system(.title3))
            Text("Mission complete")
                .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
                .foregroundColor(pillarColor)
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(pillarColor.opacity(0.10))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mission complete.")
    }
}

// MARK: - MoodSwitchSheet

/// Bottom sheet presented when the user's mood has changed since they last
/// opened this mission. Offers to adapt the content to their current mood.
struct MoodSwitchSheet: View {
    let previousMood: Mood
    let currentMood: Mood
    let pillarColor: Color
    let onKeep: () -> Void
    let onSwitch: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    MoodPill(mood: previousMood, label: "Started")
                    Image(systemName: "arrow.right")
                        .font(.system(.subheadline)).fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    MoodPill(mood: currentMood, label: "Today")
                }
                .padding(.top, 8)

                VStack(spacing: 8) {
                    Text("You're feeling different today.")
                        .font(.system(.title3, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("You started this mission feeling \(previousMood.rawValue.lowercased()). Today you're \(currentMood.rawValue.lowercased()). Want to see a different version?")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 10) {
                    Button(action: onSwitch) {
                        Text("Switch to \(currentMood.rawValue) version →")
                            .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14).fill(currentMood.color)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: onKeep) {
                        Text("Keep \(previousMood.rawValue.lowercased()) version")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - MoodPill

/// A small labelled pill showing a mood icon and name — used in `MoodSwitchSheet`.
struct MoodPill: View {
    let mood: Mood
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(.caption2, design: .rounded)).fontWeight(.bold)
                .foregroundColor(.secondary)
                .tracking(1)

            HStack(spacing: 5) {
                Image(systemName: mood.icon).font(.system(.caption2))
                Text(mood.rawValue)
                    .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
            }
            .foregroundColor(mood.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(mood.color.opacity(0.10))
                    .overlay(Capsule().strokeBorder(mood.color.opacity(0.25), lineWidth: 1))
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(mood.rawValue).")
    }
}
