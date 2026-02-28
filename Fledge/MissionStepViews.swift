//
//  MissionStepViews.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

// MARK: - MissionStepsView

/// Displays the full ordered list of steps for a mission along with a progress
/// bar showing how many have been checked off.
struct MissionStepsView: View {
    let steps: [MissionStep]
    let progress: MissionProgress?
    let pillarColor: Color
    let onToggle: (UUID) -> Void

    @State private var appeared = false

    var completedCount: Int {
        progress?.completedCount(for: steps) ?? 0
    }

    var progressFraction: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedCount) / Double(steps.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepsHeader
            stepRows
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private var stepsHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Steps")
                    .font(.system(.title2, design: .rounded)).fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(completedCount) of \(steps.count)")
                    .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Steps. \(completedCount) of \(steps.count) complete.")

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.07))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(pillarColor)
                        .frame(width: geo.size.width * progressFraction, height: 4)
                        .animation(.spring(response: 0.4), value: progressFraction)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .accessibilityHidden(true)
        }
    }

    private var stepRows: some View {
        VStack(spacing: 10) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                MissionStepRow(
                    step: step,
                    isChecked: progress?.isChecked(step.id) ?? false,
                    pillarColor: pillarColor,
                    index: index,
                    autoExpand: index == (steps.firstIndex(where: { !(progress?.isChecked($0.id) ?? false) }) ?? 0)
                ) {
                    onToggle(step.id)
                }
                .opacity(appeared ? 1 : 0)
                .animation(
                    .easeOut(duration: 0.25).delay(0.1 + Double(index) * 0.06),
                    value: appeared
                )
            }
        }
    }
}

// MARK: - MissionStepRow

/// A single expandable step row. Tapping the title expands it to show the
/// how-to instructions and optional tip; tapping the circle toggles completion.
struct MissionStepRow: View {
    let step: MissionStep
    let isChecked: Bool
    let pillarColor: Color
    let index: Int
    let autoExpand: Bool
    let onToggle: () -> Void

    @State private var isExpanded = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            if isExpanded { expandedDetail }
        }
        .clipped()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(isChecked
                    ? pillarColor.opacity(0.05)
                    : Color.primary.opacity(colorScheme == .dark ? 0.05 : 0.03)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isChecked ? pillarColor.opacity(0.15) : Color.primary.opacity(0.06),
                            lineWidth: 1
                        )
                )
        }
        .opacity(isChecked ? 0.65 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isChecked)
        .onAppear { isExpanded = autoExpand }
        .sensoryFeedback(isChecked ? .impact(weight: .medium) : .impact(weight: .light), trigger: isChecked)
        .sensoryFeedback(.selection, trigger: isExpanded)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 14) {
            checkboxButton
            titleAndChevron
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var checkboxButton: some View {
        Button(action: onToggle) {
            ZStack {
                Circle()
                    .fill(isChecked ? pillarColor : Color.clear)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isChecked ? pillarColor : Color.primary.opacity(0.18),
                                lineWidth: 1.5
                            )
                    )
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(.caption2)).fontWeight(.bold)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(step.number)")
                        .font(.system(.caption2, design: .rounded)).fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .animation(.spring(response: 0.3), value: isChecked)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isChecked
            ? "Step \(step.number): \(step.action). Completed."
            : "Step \(step.number): \(step.action).")
        .accessibilityHint(isChecked
            ? "Double-tap to uncheck this step."
            : "Double-tap to mark this step as complete.")
    }

    private var titleAndChevron: some View {
        HStack(spacing: 8) {
            Text(step.action)
                .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
                .foregroundColor(isChecked ? .secondary : .primary)
                .strikethrough(isChecked, color: .secondary.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(.caption2)).fontWeight(.semibold)
                .foregroundColor(.secondary.opacity(0.35))
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isExpanded)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(step.action)
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityHint("Double-tap to \(isExpanded ? "collapse" : "expand") step details.")
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var expandedDetail: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle()
                .fill(Color.primary.opacity(0.05))
                .frame(height: 1)
                .padding(.horizontal, 16)

            Text(step.howTo)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
                .padding(.horizontal, 16)

            if let tip = step.tip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(.caption2))
                        .foregroundColor(pillarColor)
                        .padding(.top, 1)
                        .accessibilityHidden(true)
                    Text(tip)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(pillarColor.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(pillarColor.opacity(0.08))
                )
                .padding(.horizontal, 16)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Tip: \(tip)")
            }
        }
        .padding(.bottom, 14)
        .transition(.opacity)
    }
}

// MARK: - MissionResourcesView

/// A list of supplementary resources (apps, places, tips, costs) for a mission.
struct MissionResourcesView: View {
    let resources: [MissionResource]
    let pillarColor: Color
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Resources")
                .font(.system(.title2, design: .rounded)).fontWeight(.bold)
                .foregroundColor(.primary)

            VStack(spacing: 12) {
                ForEach(resources) { resource in
                    resourceRow(resource)
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.3).delay(
                                Double(resources.firstIndex(where: { $0.id == resource.id }) ?? 0) * 0.06
                            ),
                            value: appeared
                        )
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private func resourceRow(_ resource: MissionResource) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(resource.icon)
                .font(.system(.title3))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.05))
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(resource.name)
                    .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(resource.detail)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(resource.name). \(resource.detail).")
    }
}
