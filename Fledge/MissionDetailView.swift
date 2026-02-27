//
//  MissionDetailView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI
import SwiftData

struct MissionDetailView: View {
    @Bindable var mission: Mission
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var moodManager: MoodManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userProfile: UserProfile

    @State private var state = MissionDetailState()
    @State private var appeared = false

    // MARK: - Derived state

    var pillarColor: Color {
        colorScheme == .dark ? mission.pillar.color : mission.pillar.lightModeColor
    }

    var currentSteps: [MissionStep]    { mission.activeSteps(for: state.activeMood) }
    var currentResources: [MissionResource] { mission.activeResources(for: state.activeMood) }

    var completedCount: Int  { mission.progress?.completedCount(for: currentSteps) ?? 0 }
    var allStepsComplete: Bool { mission.progress?.isAllComplete(for: currentSteps) ?? false }
    var progressFraction: Double {
        guard !currentSteps.isEmpty else { return 0 }
        return Double(completedCount) / Double(currentSteps.count)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            detailBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MissionHeroView(mission: mission, pillarColor: pillarColor)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    if MissionData.isLocked(mission) { lockedBanner }

                    briefingAndTruth
                    stepsSection

                    Spacer(minLength: 140)
                }
            }

            bottomBarOverlay

            if state.showWinCard && !state.showMoment && state.justCompleted {
                WinCardView(
                    winText: mission.win.text(for: state.activeMood)
                        .personalized(name: userProfile.name, city: userProfile.city),
                    xpValue: mission.xpValue,
                    pillarColor: pillarColor
                ) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        mission.isComplete = true
                        state.showMoment = true
                    }
                    MissionStore.save(mission)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(9)
            }

            if state.showMoment {
                FledgeMomentView(pillarColor: pillarColor, pillar: mission.pillar) {
                    withAnimation(.easeInOut(duration: 0.4)) { state.showMoment = false }
                    dismiss()
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .sensoryFeedback(.success, trigger: state.justCompleted)
        .sensoryFeedback(.impact(weight: .heavy), trigger: state.activeMood)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { backButton }
        }
        .sheet(isPresented: $state.showMoodSwitch) { moodSwitchSheet }
        .onAppear { configureOnAppear() }
    }

    // MARK: - Background

    private var detailBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [pillarColor.opacity(0.08), Color.clear],
                center: .top, startRadius: 0, endRadius: 350
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Locked banner

    private var lockedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill").font(.system(.footnote))
            VStack(alignment: .leading, spacing: 2) {
                Text("Mission locked")
                    .font(.system(.footnote, design: .rounded)).fontWeight(.bold)
                Text("Complete \"\(mission.prerequisiteTitle)\" first")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .foregroundColor(.secondary)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
        }
        .padding(.top, 12)
        .padding(.horizontal, 20)
    }

    // MARK: - Briefing and truth

    private var briefingAndTruth: some View {
        VStack(alignment: .leading, spacing: 0) {
            MoodAdaptiveSection(
                label: "BRIEFING",
                icon: "bolt.fill",
                content: mission.briefing.text(for: state.activeMood)
                    .personalized(name: userProfile.name, city: userProfile.city),
                color: pillarColor,
                style: .briefing,
                appeared: appeared,
                delay: 0.10
            )
            .padding(.top, 32)
            .padding(.horizontal, 20)

            ObjectiveView(
                objective: mission.objective,
                pillarColor: pillarColor,
                appeared: appeared
            )
            .padding(.top, 24)
            .padding(.horizontal, 20)

            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .opacity(appeared ? 1 : 0)

            MoodAdaptiveSection(
                label: "THE TRUTH",
                icon: "quote.opening",
                content: mission.truth.text(for: state.activeMood)
                    .personalized(name: userProfile.name, city: userProfile.city),
                color: pillarColor,
                style: .standard,
                appeared: appeared,
                delay: 0.20
            )
            .padding(.top, 28)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Steps section

    @ViewBuilder
    private var stepsSection: some View {
        if state.showMove || mission.isComplete {
            VStack(alignment: .leading, spacing: 0) {
                MissionStepsView(
                    steps: currentSteps,
                    progress: mission.progress,
                    pillarColor: pillarColor,
                    onToggle: { stepId in
                        var updated = mission.progress ?? MissionProgress(
                            startingMood: state.activeMood,
                            activeMood: state.activeMood,
                            checkedStepIds: []
                        )
                        updated.toggle(stepId)
                        updated.activeMood = state.activeMood
                        mission.progress = updated
                        MissionStore.save(mission)
                    }
                )
                .padding(.top, 36)
                .padding(.horizontal, 20)
                .transition(.opacity)

                if !currentResources.isEmpty {
                    MissionResourcesView(resources: currentResources, pillarColor: pillarColor)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                }
            }
        } else {
            RevealMoveButton(pillarColor: pillarColor) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    state.showMove = true
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
        }
    }

    // MARK: - Bottom bar overlay

    private var bottomBarOverlay: some View {
        VStack {
            Spacer()
            if state.showMove && !mission.isComplete && !state.showWinCard && !state.showMoment {
                MissionBottomBar(
                    progressFraction: progressFraction,
                    completedCount: completedCount,
                    totalCount: currentSteps.count,
                    allStepsComplete: allStepsComplete,
                    pillarColor: pillarColor,
                    xpValue: mission.xpValue
                ) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        state.justCompleted = true
                        state.showWinCard = true
                        userProfile.totalXP += mission.xpValue
                    }
                    #if os(iOS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { }
                    #endif
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if mission.isComplete && !state.justCompleted {
                CompletedBadge(pillarColor: pillarColor)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Toolbar back button

    private var backButton: some View {
        Button { dismiss() } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(.subheadline)).fontWeight(.semibold)
                Text("Back")
                    .font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
            }
            .foregroundColor(pillarColor)
        }
    }

    // MARK: - Mood switch sheet

    private var moodSwitchSheet: some View {
        MoodSwitchSheet(
            previousMood: mission.progress?.startingMood ?? state.activeMood,
            currentMood: moodManager.currentMood,
            pillarColor: pillarColor,
            onKeep: {
                state.showMoodSwitch = false
            },
            onSwitch: {
                state.activeMood = moodManager.currentMood
                var updated = mission.progress ?? MissionProgress(
                    startingMood: moodManager.currentMood,
                    activeMood: moodManager.currentMood,
                    checkedStepIds: []
                )
                updated.activeMood = moodManager.currentMood
                mission.progress = updated
                MissionStore.save(mission)
                state.showMoodSwitch = false
            }
        )
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Lifecycle

    private func configureOnAppear() {
        if let existing = mission.progress {
            state.activeMood = existing.activeMood
            if existing.startingMood != moodManager.currentMood &&
               existing.activeMood != moodManager.currentMood &&
               !mission.isComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    state.showMoodSwitch = true
                }
            }
        } else {
            state.activeMood = moodManager.currentMood
            mission.progress = MissionProgress(
                startingMood: moodManager.currentMood,
                activeMood: moodManager.currentMood,
                checkedStepIds: []
            )
        }

        if mission.isComplete {
            DispatchQueue.main.async { state.showMove = true }
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            appeared = true
        }
    }
}

// MARK: - Mission detail state

/// Value type consolidating all UI state for `MissionDetailView`.
/// Keeping this separate from `appeared` lets the entrance animation
/// stay independent of mission-flow state changes.
private struct MissionDetailState {
    var activeMood: Mood      = .ready
    var showMoodSwitch        = false
    var showMove              = false
    var showWinCard           = false
    var showMoment            = false
    var justCompleted         = false
}
