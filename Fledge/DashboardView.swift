//
//  DashboardView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var moodManager: MoodManager

    @State private var selectedPillar: Pillar = .city
    @State private var appeared = false
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isSearchFocused: Bool
    
    var isSearchActive: Bool { isSearchFocused || !searchText.isEmpty }

    var searchResults: [Mission] {
        guard !searchText.isEmpty else { return [] }
        return MissionData.all.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    func isLocked(_ mission: Mission) -> Bool {
        guard let prereqID = mission.prerequisiteMissionID else { return false }
        return !(MissionData.mission(withID: prereqID)?.isComplete ?? false)
    }

    var upcomingMissions: [(week: Int, missions: [Mission])] {
        let nextWeek = arrivalManager.currentWeek + 1
        guard nextWeek <= 4 else { return [] }
        return (nextWeek...4).compactMap { week in
            let missions = MissionData.missions(forWeek: week, pillar: selectedPillar)
            return missions.isEmpty ? nil : (week: week, missions: missions)
        }
    }

    var pastUncompletedMissions: [(week: Int, missions: [Mission])] {
        let previousWeeks = 1..<arrivalManager.currentWeek
        guard !previousWeeks.isEmpty else { return [] }
        return previousWeeks.compactMap { week in
            let missions = MissionData.missions(forWeek: week, pillar: selectedPillar)
                .filter { !$0.isComplete }
            return missions.isEmpty ? nil : (week: week, missions: missions)
        }
    }

    var currentMissions: [Mission] {
        MissionData.missions(
            forWeek: arrivalManager.currentWeek,
            pillar: selectedPillar,
            tags: userProfile.relevantTags
        )
    }

    var completedCount: Int {
        MissionData.missions(forWeek: arrivalManager.currentWeek).filter { $0.isComplete }.count
    }

    var totalCount: Int {
        MissionData.missions(forWeek: arrivalManager.currentWeek).count
    }

    var weekLabel: String {
        switch arrivalManager.currentWeek {
        case 1: return "Your first week."
        case 2: return "Finding your rhythm."
        case 3: return "Getting comfortable."
        case 4: return "One month in."
        default: return "Keep going."
        }
    }

    var greetingLabel: String {
        switch moodManager.currentMood {
        case .overwhelmed: return "One thing at a time. You've got this."
        case .lonely:      return "Your people are closer than they feel."
        case .ready:
            switch userProfile.goal {
            case "Staying healthy":   return "Stay strong out there."
            case "Saving money":      return "Make every peso count."
            case "Exploring the city":return "The city is waiting."
            case "Meeting people":    return "Your people are out there."
            default:                  return "Let's keep going."
            }
        }
    }

    private var weekSimulatorBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(.footnote))
                .foregroundColor(.orange)
            Text("Simulating Week \(arrivalManager.weekOverride)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.orange)
            Spacer()
            Button("Reset") { arrivalManager.stopSimulating() }
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.10))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // ── Background ─────────────────────────────────────────────
                LinearGradient(
                                    colors: colorScheme == .dark
                                        ? moodManager.currentMood.atmosphereColors
                                        : moodManager.currentMood.lightModeAtmosphereColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .ignoresSafeArea()
                                .animation(.easeInOut(duration: 2.0), value: moodManager.currentMood)

                                // Tap-to-dismiss when search is active
                                if isSearchActive {
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .ignoresSafeArea()
                                        .onTapGesture { dismissSearch() }
                                }

                                RadialGradient(
                                    colors: [moodManager.currentMood.atmosphereGlowColor.opacity(
                                        colorScheme == .dark ? 0.18 : 0.12
                                    ), Color.clear],
                                    center: .top, startRadius: 0, endRadius: 400
                                )
                                .ignoresSafeArea()
                                .animation(.easeInOut(duration: 2.0), value: moodManager.currentMood)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 4)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)

                        if !isSearchActive {
                            MorphingPillarSwitcher(selectedPillar: $selectedPillar)
                                .padding(.top, 28)
                                .opacity(appeared ? 1 : 0)
                                .transition(.opacity.combined(with: .offset(y: -8)))
                        } else {
                            ActivePillarPill(
                                pillar: selectedPillar,
                                colorScheme: colorScheme
                            ) { dismissSearch() }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .transition(.opacity.combined(with: .offset(y: 8)))
                        }

                        if isSearchActive {
                            searchResultsSection
                        } else {
                            normalMissionList
                        }

                        Spacer(minLength: 100).opacity(0)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .animation(.spring(response: 0.42, dampingFraction: 0.82), value: isSearchActive)
            }
            .sensoryFeedback(.selection, trigger: selectedPillar)
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .onAppear {
                if !appeared {
                    switch moodManager.currentMood {
                    case .overwhelmed: selectedPillar = .adultMode
                    case .lonely:      selectedPillar = .growth
                    case .ready:       selectedPillar = .city
                    }
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }


    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Top row: week label + mood icon (always visible)
            HStack {
                Text("Week \(arrivalManager.currentWeek)")
                    .font(.system(.callout, design: .rounded)).fontWeight(.bold)
                    .foregroundColor(Color.accentColor)
                    .textCase(.uppercase)
                    .tracking(2)
                Spacer()
                NavigationLink(destination: MoodResourcesView(mood: moodManager.currentMood)) {
                    Image(systemName: moodManager.currentMood.icon)
                        .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                        .foregroundColor(moodManager.currentMood.color)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(moodManager.currentMood.color.opacity(0.12))
                                .overlay(
                                    Circle().strokeBorder(moodManager.currentMood.color.opacity(0.40), lineWidth: 1.5)
                                )
                                .shadow(color: moodManager.currentMood.color.opacity(0.25), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(.plain)
            }

            // Big week title — collapses cleanly when search is active
            if !isSearchActive {
                Text(weekLabel)
                    .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                    .foregroundColor(.primary)
                    .transition(.opacity.combined(with: .offset(y: -6)))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor)
                            .frame(
                                width: geo.size.width * Double(completedCount) / Double(max(totalCount, 1)),
                                height: 4
                            )
                            .animation(.spring(response: 0.6), value: completedCount)
                    }
                }
                .frame(height: 4)
                .padding(.top, 2)
                .transition(.opacity)
            }

            // Search bar — always present
            searchBar
                .padding(.top, isSearchActive ? 6 : 16)
        }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                .foregroundColor(isSearchActive
                    ? Color.accentColor
                    : Color.secondary.opacity(0.7))
                .animation(.easeInOut(duration: 0.2), value: isSearchActive)

            TextField("Search missions...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .focused($isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled(true)

            if !searchText.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.6))
                        .font(.system(.title3))
                }
                .transition(.scale.combined(with: .opacity))
            }

            if isSearchActive && searchText.isEmpty {
                Button("Cancel") { dismissSearch() }
                    .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(Color.accentColor)
                    .transition(.opacity.combined(with: .offset(x: 10)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isSearchActive
                                ? Color.accentColor.opacity(0.30)
                                : Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05),
                            lineWidth: 1
                        )
                        .animation(.easeInOut(duration: 0.2), value: isSearchActive)
                )
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 8, y: 4)
        }
    }

    // MARK: - Search results section

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            if searchText.isEmpty {
                // Keyboard is up, no query yet — show a prompt
                SearchEmptyPrompt()
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            } else if searchResults.isEmpty {
                SearchNoResults(query: searchText)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            } else {
                // Result count
                HStack {
                    Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                        .font(.system(.footnote, design: .rounded)).fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(1.0)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 8)

                LazyVStack(spacing: 10) {
                    ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, mission in
                        let locked = isLocked(mission)
                        if locked {
                            SearchMissionRow(
                                mission: mission,
                                index: index,
                                isLocked: true,
                                currentWeek: arrivalManager.currentWeek
                            )
                        } else {
                            NavigationLink(
                                destination: MissionDetailView(mission: mission)
                                    .environmentObject(userProfile)
                            ) {
                                SearchMissionRow(
                                    mission: mission,
                                    index: index,
                                    isLocked: false,
                                    currentWeek: arrivalManager.currentWeek
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Normal mission list

    private var normalMissionList: some View {
        VStack(alignment: .leading, spacing: 0) {

            // "This week" header
            HStack {
                Text("This week")
                    .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
                // Week simulator menu
                Menu {
                    ForEach(1...4, id: \.self) { week in
                        Button("Simulate Week \(week)") { arrivalManager.simulateWeek(week) }
                    }
                    if arrivalManager.weekOverride > 0 {
                        Button("Stop Simulating", role: .destructive) { arrivalManager.stopSimulating() }
                    }
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(.callout))
                        .foregroundStyle(.secondary.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 2)
            .opacity(appeared ? 1 : 0)

            // Week simulator banner
            if arrivalManager.weekOverride > 0 {
                weekSimulatorBanner
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
            }

            // All pillar-dependent content crossfades together when selectedPillar changes.
            // The .id forces SwiftUI to fully replace this container on pillar switch, and
            // .transition(.opacity) with an explicit .animation breaks the inherited spring
            // from the pillar card tap so the list animates independently.
            VStack(alignment: .leading, spacing: 0) {

                // Current missions
                LazyVStack(spacing: 10) {
                    if currentMissions.isEmpty {
                        GlassEmptyStateView(pillar: selectedPillar)
                    } else {
                        ForEach(Array(currentMissions.enumerated()), id: \.element.id) { index, mission in
                            let locked = isLocked(mission)
                            if locked {
                                GlassMissionRow(mission: mission, index: index, isLocked: true)
                            } else {
                                NavigationLink(
                                    destination: MissionDetailView(mission: mission)
                                        .environmentObject(userProfile)
                                ) {
                                    GlassMissionRow(mission: mission, index: index, isLocked: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                // Past uncompleted
                ForEach(pastUncompletedMissions, id: \.week) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath").font(.system(.caption2)).fontWeight(.semibold)
                            Text("From Week \(item.week)")
                                .font(.system(.callout, design: .rounded)).fontWeight(.semibold)
                                .tracking(1.2)
                        }
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 2)

                        LazyVStack(spacing: 10) {
                            ForEach(Array(item.missions.enumerated()), id: \.element.id) { index, mission in
                                let locked = isLocked(mission)
                                if locked {
                                    GlassMissionRow(mission: mission, index: index, isLocked: true)
                                } else {
                                    NavigationLink(
                                        destination: MissionDetailView(mission: mission)
                                            .environmentObject(userProfile)
                                    ) {
                                        GlassMissionRow(mission: mission, index: index, isLocked: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Upcoming weeks (teaser)
                ForEach(upcomingMissions, id: \.week) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Week \(item.week)")
                            .font(.system(.callout, design: .rounded)).fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                            .padding(.bottom, 2)

                        LazyVStack(spacing: 10) {
                            ForEach(Array(item.missions.enumerated()), id: \.element.id) { index, mission in
                                UpcomingMissionRow(
                                    mission: mission,
                                    index: index,
                                    pillarColor: colorScheme == .dark ? mission.pillar.color : mission.pillar.lightModeColor
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .id(selectedPillar)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.22), value: selectedPillar)
            .opacity(appeared ? 1 : 0)
        }
    }

    // MARK: - Helpers

    private func dismissSearch() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            isSearchFocused = false
            searchText = ""
        }
    }
}

// MARK: - Active pillar pill (shown during search instead of the full hero switcher)

private struct ActivePillarPill: View {
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
    }
}

// MARK: - Search-specific mission row (shows week + pillar badge)

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

    var body: some View {
        HStack(spacing: 14) {
            // Pillar icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(pillarColor.opacity(isLocked ? 0.06 : 0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(pillarColor.opacity(isLocked ? 0.12 : 0.25), lineWidth: 1)
                    )
                Image(systemName: isLocked ? "lock.fill" : mission.pillar.icon)
                    .font(.system(isLocked ? .title3 : .title2)) // FIXED: Removed size:
                    .foregroundColor(isLocked ? .secondary.opacity(0.4) : pillarColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 5) {
                Text(mission.title)
                    .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                    .foregroundColor(isLocked ? .secondary : .primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // Pillar badge
                    Text(mission.pillar.rawValue)
                        .font(.system(.caption2, design: .rounded)).fontWeight(.bold) // FIXED: Removed size:
                        .foregroundColor(pillarColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(pillarColor.opacity(0.12))
                        )

                    // Week badge
                    Text(isCurrentWeek ? "This week" : "Week \(mission.weekNumber)")
                        .font(.system(.caption2, design: .rounded)).fontWeight(.semibold) // FIXED: Typo .cation2 -> .caption2
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
                .font(.system(mission.isComplete ? .title2 : .callout)).fontWeight(.semibold) // FIXED: Removed size:
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
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.80).delay(Double(index) * 0.04)) {
                appeared = true
            }
        }
    }
}

// MARK: - Search empty states

private struct SearchEmptyPrompt: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(.title)) // FIXED: .title1 doesn't exist
                .foregroundColor(.secondary.opacity(0.35))
            Text("Type to search all missions")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.secondary.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

private struct SearchNoResults: View {
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(.title)) // FIXED: .title1 doesn't exist
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
    }
}

// MARK: - Morphing Hero Pillar Switcher (unchanged) ─────────────────────────

struct MorphingPillarSwitcher: View {
    @Binding var selectedPillar: Pillar
    @Namespace private var heroNamespace
    @Environment(\.colorScheme) var colorScheme

    var accessoryPillars: [Pillar] {
        Pillar.allCases.filter { $0 != selectedPillar }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            HeroPillarCard(pillar: selectedPillar, namespace: heroNamespace, colorScheme: colorScheme)
                .frame(maxWidth: .infinity)
                .frame(height: 160)

            VStack(spacing: 10) {
                ForEach(accessoryPillars, id: \.self) { pillar in
                    AccessoryPillarCard(pillar: pillar, namespace: heroNamespace, colorScheme: colorScheme) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                            selectedPillar = pillar
                        }
                    }
                    .frame(height: 75)
                }
            }
            .frame(width: 110)
        }
        .padding(.horizontal, 16)
    }
}

struct HeroPillarCard: View {
    @State private var showTagline = true
    let pillar: Pillar
    var namespace: Namespace.ID
    var colorScheme: ColorScheme

    var effectiveColor: Color {
        colorScheme == .dark ? pillar.color : pillar.lightModeColor
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(effectiveColor.opacity(colorScheme == .dark ? 0.18 : 0.11))
                .matchedGeometryEffect(id: "bg_\(pillar.rawValue)", in: namespace)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(effectiveColor.opacity(0.30), lineWidth: 1.2)
                        .matchedGeometryEffect(id: "border_\(pillar.rawValue)", in: namespace)
                )

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Image(systemName: pillar.icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(effectiveColor)
                    .matchedGeometryEffect(id: "icon_\(pillar.rawValue)", in: namespace)
                    .padding(.bottom, 10)
                Text(pillar.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .matchedGeometryEffect(id: "label_\(pillar.rawValue)", in: namespace)
                Text(pillar.tagline)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 2)
                    .opacity(showTagline ? 0.85 : 0)
                    .onChange(of: pillar) {
                        showTagline = false
                        withAnimation(.easeIn(duration: 0.25).delay(0.35)) { showTagline = true }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct AccessoryPillarCard: View {
    let pillar: Pillar
    var namespace: Namespace.ID
    var colorScheme: ColorScheme
    let action: () -> Void

    var effectiveColor: Color {
        colorScheme == .dark ? pillar.color : pillar.lightModeColor
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.04))
                    .matchedGeometryEffect(id: "bg_\(pillar.rawValue)", in: namespace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            .matchedGeometryEffect(id: "border_\(pillar.rawValue)", in: namespace)
                    )
                VStack(spacing: 6) {
                    Image(systemName: pillar.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(effectiveColor.opacity(0.75))
                        .matchedGeometryEffect(id: "icon_\(pillar.rawValue)", in: namespace)
                    Text(pillar.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .matchedGeometryEffect(id: "label_\(pillar.rawValue)", in: namespace)
                }
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - GlassMissionRow (unchanged) ────────────────────────────────────────

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

// MARK: - Remaining subviews (unchanged) ─────────────────────────────────────

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
