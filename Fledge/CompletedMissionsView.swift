//
//  CompletedMissionsView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 27/02/26.
//

import SwiftUI

// MARK: - Main View

struct CompletedMissionsView: View {
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var selectedPillar: Pillar? = nil
    @State private var appeared = false

    // MARK: Data

    var allCompleted: [Mission] {
        MissionData.all.filter { $0.isComplete }
    }

    var filtered: [Mission] {
        guard let pillar = selectedPillar else { return allCompleted }
        return allCompleted.filter { $0.pillar == pillar }
    }

    // Grouped by week, ascending
    var groupedByWeek: [(week: Int, missions: [Mission])] {
        let weeks = Set(filtered.map { $0.weekNumber }).sorted()
        return weeks.map { week in
            let missions = filtered
                .filter { $0.weekNumber == week }
                .sorted { $0.pillar.rawValue < $1.pillar.rawValue }
            return (week: week, missions: missions)
        }
    }

    var totalXP: Int { allCompleted.reduce(0) { $0 + $1.xpValue } }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ZStack {
                // ── Background — same dark as Journey Stats panel ──────────
                Color(red: 0.02, green: 0.02, blue: 0.10)
                    .ignoresSafeArea()

                // Subtle radial glow at top
                RadialGradient(
                    colors: [Color.white.opacity(0.04), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()

                if allCompleted.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {

                            // ── Stats bar ──────────────────────────────────
                            statsBar
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                                .opacity(appeared ? 1 : 0)

                            // ── Pillar filter ──────────────────────────────
                            pillarFilter
                                .padding(.bottom, 28)
                                .opacity(appeared ? 1 : 0)
                                .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                            // ── Mission groups ─────────────────────────────
                            if filtered.isEmpty {
                                filterEmptyState
                                    .padding(.horizontal, 24)
                            } else {
                                ForEach(groupedByWeek, id: \.week) { group in
                                    weekGroup(group)
                                }
                            }

                            Spacer(minLength: 80)
                        }
                    }
                }
            }
            .navigationTitle("Completed")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.02, green: 0.02, blue: 0.10), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(.title3))
                            .foregroundStyle(Color.white.opacity(0.35))
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 16) {
            // Missions count
            VStack(alignment: .leading, spacing: 3) {
                Text("\(allCompleted.count)")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("missions")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color.white.opacity(0.40))
            }

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 1, height: 36)

            // Total XP
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(.callout))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.40))
                    Text("\(totalXP) XP")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Text("earned total")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color.white.opacity(0.40))
            }

            Spacer()
        }
    }

    // MARK: - Pillar Filter

    private var pillarFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                PillarFilterChip(
                    label: "All",
                    icon: "square.grid.2x2",
                    color: .white,
                    isSelected: selectedPillar == nil,
                    count: allCompleted.count
                ) { withAnimation(.spring(response: 0.35)) { selectedPillar = nil } }

                ForEach(Pillar.allCases, id: \.self) { pillar in
                    let count = allCompleted.filter { $0.pillar == pillar }.count
                    PillarFilterChip(
                        label: pillar.rawValue,
                        icon: pillar.icon,
                        color: pillar.skyColor,
                        isSelected: selectedPillar == pillar,
                        count: count
                    ) {
                        withAnimation(.spring(response: 0.35)) {
                            selectedPillar = selectedPillar == pillar ? nil : pillar
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Week Group

    private func weekGroup(_ group: (week: Int, missions: [Mission])) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Week eyebrow
            HStack(spacing: 6) {
                Text("Week \(group.week)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white.opacity(0.35))
                    .textCase(.uppercase)
                    .tracking(1.5)
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 2)

            // Mission cards
            LazyVStack(spacing: 8) {
                ForEach(Array(group.missions.enumerated()), id: \.element.id) { index, mission in
                    NavigationLink(
                        destination: MissionDetailView(mission: mission)
                            .environmentObject(userProfile)
                    ) {
                        CompletedMissionCard(mission: mission)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 28)
    }

    // MARK: - Empty States

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("Your log is empty")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.white.opacity(0.55))
            Text("Complete your first mission and\nit will appear here.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color.white.opacity(0.30))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private var filterEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: selectedPillar?.icon ?? "square.grid.2x2")
                .font(.system(size: 28))
                .foregroundColor(Color.white.opacity(0.18))
            Text("No completed \(selectedPillar?.rawValue ?? "") missions yet.")
                .font(.system(.callout, design: .rounded))
                .foregroundColor(Color.white.opacity(0.30))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Pillar Filter Chip

struct PillarFilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(.caption))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? color : Color.white.opacity(0.45))
                Text(label)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.45))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? color : Color.white.opacity(0.25))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(isSelected ? color.opacity(0.20) : Color.white.opacity(0.05))
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                Capsule()
                    .fill(isSelected ? color.opacity(0.15) : Color.white.opacity(0.06))
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                isSelected ? color.opacity(0.40) : Color.white.opacity(0.10),
                                lineWidth: 1
                            )
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Completed Mission Card

struct CompletedMissionCard: View {
    let mission: Mission
    @State private var appeared = false

    // The mood the user was in when they worked on this mission
    var completionMood: Mood? { mission.progress?.activeMood }

    var body: some View {
        HStack(spacing: 14) {

            // ── Pillar icon ────────────────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(mission.pillar.skyColor.opacity(0.16))
                    .frame(width: 46, height: 46)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(mission.pillar.skyColor.opacity(0.30), lineWidth: 1)
                    )
                Image(systemName: mission.pillar.icon)
                    .font(.system(.body))
                    .fontWeight(.semibold)
                    .foregroundColor(mission.pillar.skyColor)
            }

            // ── Text ───────────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text(mission.title)
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Metadata row
                HStack(spacing: 6) {
                    // XP badge
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .fontWeight(.bold)
                        Text("+\(mission.xpValue) XP")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.40).opacity(0.85))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(Color(red: 1.0, green: 0.85, blue: 0.40).opacity(0.12))
                    )

                    // Mood chip — only when available
                    if let mood = completionMood {
                        HStack(spacing: 3) {
                            Image(systemName: mood.icon)
                                .font(.system(size: 9))
                                .fontWeight(.semibold)
                            Text(mood.rawValue)
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(mood.color.opacity(0.85))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(mood.color.opacity(0.12))
                        )
                    }
                }
            }

            Spacer(minLength: 0)

            // ── Checkmark ──────────────────────────────────────────────────
            Image(systemName: "checkmark.circle.fill")
                .font(.system(.title3))
                .foregroundStyle(
                    LinearGradient(
                        colors: [mission.pillar.skyColor.opacity(0.9), mission.pillar.skyColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: mission.pillar.skyColor.opacity(0.40), radius: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(mission.pillar.skyColor.opacity(0.15), lineWidth: 1)
                )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: - Pillar sky color (matches SkyView's palette)

private extension Pillar {
    var skyColor: Color {
        switch self {
        case .city:      return Color(red: 0.5,  green: 0.65, blue: 1.0)
        case .adultMode: return Color(red: 1.0,  green: 0.65, blue: 0.45)
        case .growth:    return Color(red: 0.5,  green: 0.90, blue: 0.65)
        }
    }
}
