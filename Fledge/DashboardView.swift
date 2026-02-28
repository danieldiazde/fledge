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
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @FocusState private var isSearchFocused: Bool

    var isSearchActive: Bool { isSearchFocused || !searchText.isEmpty }

    // MARK: - Derived mission collections

    var searchResults: [Mission] {
        guard !searchText.isEmpty else { return [] }
        return MissionData.all.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var currentMissions: [Mission] {
        MissionData.missions(
            forWeek: arrivalManager.currentWeek,
            pillar: selectedPillar,
            tags: userProfile.relevantTags
        )
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

    var completedCount: Int {
        MissionData.missions(forWeek: arrivalManager.currentWeek).filter { $0.isComplete }.count
    }

    var totalCount: Int {
        MissionData.missions(forWeek: arrivalManager.currentWeek).count
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                atmosphericBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                            .padding(.horizontal, DashboardLayout.sectionInset)
                            .padding(.bottom, 4)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 16))

                        pillarSwitcherSection

                        if isSearchActive {
                            searchResultsSection
                        } else {
                            normalMissionList
                        }

                        Spacer(minLength: DashboardLayout.scrollBottomPad).opacity(0)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.42, dampingFraction: 0.82), value: isSearchActive)
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
                withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Background

    private var atmosphericBackground: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? moodManager.currentMood.atmosphereColors
                    : moodManager.currentMood.lightModeAtmosphereColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(reduceMotion ? .easeInOut(duration: 0.3) : .easeInOut(duration: 2.0), value: moodManager.currentMood)

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
            .animation(reduceMotion ? .easeInOut(duration: 0.3) : .easeInOut(duration: 2.0), value: moodManager.currentMood)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
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
                .accessibilityLabel("Current mood: \(moodManager.currentMood.rawValue).")
                .accessibilityHint("Tap to view mood-based resources.")
            }

            if !isSearchActive {
                Text(arrivalManager.weekLabel)
                    .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                    .foregroundColor(.primary)
                    .transition(.opacity.combined(with: .offset(y: -6)))

                weekProgressBar
            }

            searchBar
                .padding(.top, isSearchActive ? 6 : 16)
        }
    }

    private var weekProgressBar: some View {
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
                    .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.6), value: completedCount)
            }
        }
        .frame(height: 4)
        .padding(.top, 2)
        .transition(.opacity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(completedCount) of \(totalCount) missions complete this week.")
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
                    withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.3)) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.6))
                        .font(.system(.title3))
                }
                .accessibilityLabel("Clear search")
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

    // MARK: - Pillar switcher section

    @ViewBuilder
    private var pillarSwitcherSection: some View {
        if !isSearchActive {
            MorphingPillarSwitcher(selectedPillar: $selectedPillar)
                .padding(.top, DashboardLayout.sectionTopPad)
                .opacity(appeared ? 1 : 0)
                .transition(.opacity.combined(with: .offset(y: -8)))
        } else {
            ActivePillarPill(
                pillar: selectedPillar,
                colorScheme: colorScheme
            ) { dismissSearch() }
            .padding(.horizontal, DashboardLayout.sectionInset)
            .padding(.top, 16)
            .transition(.opacity.combined(with: .offset(y: 8)))
        }
    }

    // MARK: - Search results section

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if searchText.isEmpty {
                SearchEmptyPrompt()
                    .padding(.horizontal, DashboardLayout.cardInset)
                    .padding(.top, 24)
            } else if searchResults.isEmpty {
                SearchNoResults(query: searchText)
                    .padding(.horizontal, DashboardLayout.cardInset)
                    .padding(.top, 24)
            } else {
                HStack {
                    Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                        .font(.system(.footnote, design: .rounded)).fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(1.0)
                    Spacer()
                }
                .padding(.horizontal, DashboardLayout.sectionInset)
                .padding(.top, 22)
                .padding(.bottom, 8)

                LazyVStack(spacing: 10) {
                    ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, mission in
                        searchMissionRowLink(mission, index: index)
                    }
                }
                .padding(.horizontal, DashboardLayout.cardInset)
            }
        }
    }

    // MARK: - Normal mission list

    private var normalMissionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            thisWeekHeader

            if arrivalManager.weekOverride > 0 {
                weekSimulatorBanner
                    .padding(.horizontal, DashboardLayout.cardInset)
                    .padding(.top, 4)
            }

            pillarMissionContent
        }
    }

    private var thisWeekHeader: some View {
        HStack {
            Text("This week")
                .font(.system(.headline, design: .rounded)).fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(DashboardLayout.sectionTracking)
            Spacer()
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
            .accessibilityLabel("Simulate week")
            .accessibilityHint("Opens a menu to preview a different week.")
        }
        .padding(.horizontal, DashboardLayout.sectionInset)
        .padding(.top, DashboardLayout.sectionTopPad)
        .padding(.bottom, DashboardLayout.sectionLabelBottomPad)
        .opacity(appeared ? 1 : 0)
    }

    /// All pillar-dependent rows, keyed by `selectedPillar` so SwiftUI fully replaces
    /// this container on each switch. The crossfade animation runs independently of
    /// the spring from the pillar card tap, preventing layout jumps on pillar change.
    private var pillarMissionContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            currentMissionRows
            pastUncompletedRows
            upcomingRows
        }
        .id(selectedPillar)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.22), value: selectedPillar)
        .opacity(appeared ? 1 : 0)
    }

    private var currentMissionRows: some View {
        LazyVStack(spacing: 10) {
            if currentMissions.isEmpty {
                GlassEmptyStateView(pillar: selectedPillar)
            } else {
                ForEach(Array(currentMissions.enumerated()), id: \.element.id) { index, mission in
                    missionRowLink(mission, index: index)
                }
            }
        }
        .padding(.horizontal, DashboardLayout.cardInset)
        .padding(.top, DashboardLayout.listTopPad)
    }

    private var pastUncompletedRows: some View {
        ForEach(pastUncompletedMissions, id: \.week) { item in
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.system(.caption2)).fontWeight(.semibold)
                    Text("From Week \(item.week)")
                        .font(.system(.callout, design: .rounded)).fontWeight(.semibold)
                        .tracking(DashboardLayout.sectionTracking)
                }
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, DashboardLayout.sectionInset)
                .padding(.top, DashboardLayout.sectionTopPad)
                .padding(.bottom, DashboardLayout.sectionLabelBottomPad)

                LazyVStack(spacing: 10) {
                    ForEach(Array(item.missions.enumerated()), id: \.element.id) { index, mission in
                        missionRowLink(mission, index: index)
                    }
                }
                .padding(.horizontal, DashboardLayout.cardInset)
            }
        }
    }

    private var upcomingRows: some View {
        ForEach(upcomingMissions, id: \.week) { item in
            VStack(alignment: .leading, spacing: 10) {
                Text("Week \(item.week)")
                    .font(.system(.callout, design: .rounded)).fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(DashboardLayout.sectionTracking)
                    .padding(.horizontal, DashboardLayout.sectionInset)
                    .padding(.top, DashboardLayout.sectionTopPad)
                    .padding(.bottom, DashboardLayout.sectionLabelBottomPad)

                LazyVStack(spacing: 10) {
                    ForEach(Array(item.missions.enumerated()), id: \.element.id) { index, mission in
                        UpcomingMissionRow(
                            mission: mission,
                            index: index,
                            pillarColor: colorScheme == .dark ? mission.pillar.color : mission.pillar.lightModeColor
                        )
                    }
                }
                .padding(.horizontal, DashboardLayout.cardInset)
            }
        }
    }

    // MARK: - Row link helpers

    /// Wraps a mission in a `NavigationLink` when unlocked, or renders a static
    /// locked row when its prerequisite is incomplete.
    @ViewBuilder
    private func missionRowLink(_ mission: Mission, index: Int) -> some View {
        if MissionData.isLocked(mission) {
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

    /// Same as `missionRowLink` but produces a `SearchMissionRow` with week and
    /// pillar badges for use in the search results list.
    @ViewBuilder
    private func searchMissionRowLink(_ mission: Mission, index: Int) -> some View {
        if MissionData.isLocked(mission) {
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

    // MARK: - Week simulator banner

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

    // MARK: - Helpers

    private func dismissSearch() {
        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.38, dampingFraction: 0.82)) {
            isSearchFocused = false
            searchText = ""
        }
    }
}

// MARK: - Layout constants

private enum DashboardLayout {
    /// Horizontal inset for section label rows.
    static let sectionInset:          CGFloat = 20
    /// Horizontal inset for card lists and the pillar switcher.
    static let cardInset:             CGFloat = 16
    /// Vertical gap above each section header.
    static let sectionTopPad:         CGFloat = 28
    /// Vertical gap between a section label and its first card.
    static let sectionLabelBottomPad: CGFloat = 2
    /// Top padding for the first card in the current-missions list.
    static let listTopPad:            CGFloat = 4
    /// Letter-spacing used on all uppercase section labels.
    static let sectionTracking:       CGFloat = 1.2
    /// Minimum height of the invisible spacer at the bottom of the scroll view.
    static let scrollBottomPad:       CGFloat = 100
}
