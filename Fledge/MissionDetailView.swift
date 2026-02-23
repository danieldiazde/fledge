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
    
    @State private var activeMood: Mood = .ready
    @State private var showMoodSwitch = false
    @State private var showMove = false
    @State private var showWinCard = false
    @State private var showMoment = false
    @State private var justCompleted = false
    @State private var appeared = false
    
    var isLocked: Bool {
        guard let prereqID = mission.prerequisiteMissionID else { return false }
        return !(MissionData.mission(withID: prereqID)?.isComplete ?? false)
    }

    var prerequisiteTitle: String {
        guard let prereqID = mission.prerequisiteMissionID else { return "" }
        return MissionData.mission(withID: prereqID)?.title ?? ""
    }
    
    var pillarColor: Color {
        colorScheme == .dark ? mission.pillar.color : mission.pillar.lightModeColor
    }
    
    var currentSteps: [MissionStep] { mission.activeSteps(for: activeMood) }
    var currentResources: [MissionResource] { mission.activeResources(for: activeMood) }
    
    var completedCount: Int { mission.progress?.completedCount(for: currentSteps) ?? 0 }
    var allStepsComplete: Bool { mission.progress?.isAllComplete(for: currentSteps) ?? false }
    var progressFraction: Double {
        guard !currentSteps.isEmpty else { return 0 }
        return Double(completedCount) / Double(currentSteps.count)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [pillarColor.opacity(0.08), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Hero
                    MissionHeroView(mission: mission, pillarColor: pillarColor)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    if isLocked {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 13))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mission locked")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                Text("Complete \"\(prerequisiteTitle)\" first")
                                    .font(.system(size: 12, design: .rounded))
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
                    
                    // Briefing
                    MoodAdaptiveSection(
                        label: "BRIEFING",
                        icon: "bolt.fill",
                        content: mission.briefing.text(for: activeMood),
                        color: pillarColor,
                        style: .briefing,
                        appeared: appeared,
                        delay: 0.10
                    )
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                    
                    // Objective
                    ObjectiveView(
                        objective: mission.objective,
                        pillarColor: pillarColor,
                        appeared: appeared
                    )
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    
                    // Truth
                    MoodAdaptiveSection(
                        label: "THE TRUTH",
                        icon: "quote.opening",
                        content: mission.truth.text(for: activeMood),
                        color: pillarColor,
                        style: .standard,
                        appeared: appeared,
                        delay: 0.20
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Steps
                    if showMove || mission.isComplete {
                        MissionStepsView(
                            steps: currentSteps,
                            progress: mission.progress,
                            pillarColor: pillarColor,
                            onToggle: { stepId in
                                var updated = mission.progress ?? MissionProgress(
                                    startingMood: activeMood,
                                    activeMood: activeMood,
                                    checkedStepIds: []
                                )
                                updated.toggle(stepId)
                                updated.activeMood = activeMood
                                mission.progress = updated
                            }
                        )
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                        
                        if !currentResources.isEmpty {
                            MissionResourcesView(
                                resources: currentResources,
                                pillarColor: pillarColor
                            )
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                        }
                    } else {
                        RevealMoveButton(pillarColor: pillarColor) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showMove = true
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                    }
                    
                    Spacer(minLength: 140)
                }
            }
            
            // Bottom bar
            VStack {
                Spacer()
                if showMove && !mission.isComplete && !showWinCard && !showMoment {
                    MissionBottomBar(
                        progressFraction: progressFraction,
                        completedCount: completedCount,
                        totalCount: currentSteps.count,
                        allStepsComplete: allStepsComplete,
                        pillarColor: pillarColor,
                        xpValue: mission.xpValue
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            justCompleted = true
                            showWinCard = true
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if mission.isComplete && !justCompleted {
                    CompletedBadge(pillarColor: pillarColor)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
            }
            
            // Win card
            if showWinCard && !showMoment && justCompleted {
                WinCardView(
                    winText: mission.win.text(for: activeMood),
                    xpValue: mission.xpValue,
                    pillarColor: pillarColor
                ) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        mission.isComplete = true
                        showMoment = true
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(9)
            }
            
            // Fledge moment
            if showMoment {
                FledgeMomentView(
                    winText: mission.win.text(for: activeMood),
                    pillarColor: pillarColor,
                    pillar: mission.pillar
                ) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showMoment = false
                    }
                    dismiss()
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(pillarColor)
                }
            }
        }
        .sheet(isPresented: $showMoodSwitch) {
            MoodSwitchSheet(
                previousMood: mission.progress?.startingMood ?? activeMood,
                currentMood: moodManager.currentMood,
                pillarColor: pillarColor,
                onKeep: {
                    showMoodSwitch = false
                },
                onSwitch: {
                    activeMood = moodManager.currentMood
                    var updated = mission.progress ?? MissionProgress(
                        startingMood: moodManager.currentMood,
                        activeMood: moodManager.currentMood,
                        checkedStepIds: []
                    )
                    updated.activeMood = moodManager.currentMood
                    mission.progress = updated
                    showMoodSwitch = false
                }
            )
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let existing = mission.progress {
                activeMood = existing.activeMood
                if existing.startingMood != moodManager.currentMood &&
                   existing.activeMood != moodManager.currentMood &&
                   !mission.isComplete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showMoodSwitch = true
                    }
                }
            } else {
                activeMood = moodManager.currentMood
                mission.progress = MissionProgress(
                    startingMood: moodManager.currentMood,
                    activeMood: moodManager.currentMood,
                    checkedStepIds: []
                )
            }
            
            if mission.isComplete {
                DispatchQueue.main.async {
                    showMove = true
                }
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Mission Steps View

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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.system(size: 11, weight: .bold))
                    Text("MISSION STEPS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.5)
                }
                .foregroundColor(pillarColor)
                
                Spacer()
                
                Text("\(completedCount) of \(steps.count)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(pillarColor)
                        .frame(width: geo.size.width * progressFraction, height: 3)
                        .animation(.spring(response: 0.4), value: progressFraction)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height:3)
            
            VStack(spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    MissionStepRow(
                        step: step,
                        isChecked: progress?.isChecked(step.id) ?? false,
                        pillarColor: pillarColor,
                        index: index
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
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// MARK: - Mission Step Row

struct MissionStepRow: View {
    let step: MissionStep
    let isChecked: Bool
    let pillarColor: Color
    let index: Int
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isChecked ? pillarColor : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(
                                    isChecked ? pillarColor : Color.primary.opacity(0.2),
                                    lineWidth: 1.5
                                )
                        )
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("\(step.number)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .animation(.spring(response: 0.3), value: isChecked)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.action)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(isChecked ? .secondary : .primary)
                        .strikethrough(isChecked, color: .secondary)
                    
                    Text(step.howTo)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                    
                    if let tip = step.tip {
                        HStack(spacing: 4) {
                            Text("Pro move:")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                            Text(tip)
                                .font(.system(size: 11, design: .rounded))
                        }
                        .foregroundColor(pillarColor.opacity(0.8))
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isChecked
                        ? pillarColor.opacity(0.06)
                        : Color.primary.opacity(0.03)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isChecked
                                    ? pillarColor.opacity(0.20)
                                    : Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            }
            .opacity(isChecked ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isChecked)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Mission Bottom Bar

struct MissionBottomBar: View {
    let progressFraction: Double
    let completedCount: Int
    let totalCount: Int
    let allStepsComplete: Bool
    let pillarColor: Color
    let xpValue: Int
    let onComplete: () -> Void
    
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
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                    Text("\(xpValue) XP on completion")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(pillarColor.opacity(0.7))
                
                Button(action: onComplete) {
                    HStack(spacing: 10) {
                        Image(systemName: allStepsComplete ? "checkmark" : "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(allStepsComplete ? "Mission Complete" : "Complete all steps first")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
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
                .animation(.spring(response: 0.4), value: allStepsComplete)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .background(Color("AtmosphereTop"))
        }
    }
}

// MARK: - Mood Switch Sheet

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
                // Mood transition visual
                HStack(spacing: 16) {
                    MoodPill(mood: previousMood, label: "Started")
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    MoodPill(mood: currentMood, label: "Today")
                }
                .padding(.top, 8)
                
                VStack(spacing: 8) {
                    Text("You're feeling different today.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("You started this mission feeling \(previousMood.rawValue.lowercased()). Today you're \(currentMood.rawValue.lowercased()). Want to see a different version?")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                VStack(spacing: 10) {
                    Button(action: onSwitch) {
                        Text("Switch to \(currentMood.rawValue) version →")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(currentMood.color)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onKeep) {
                        Text("Keep \(previousMood.rawValue.lowercased()) version")
                            .font(.system(size: 15, design: .rounded))
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

// MARK: - Mood Pill

struct MoodPill: View {
    let mood: Mood
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(1)
            
            HStack(spacing: 5) {
                Image(systemName: mood.icon)
                    .font(.system(size: 11))
                Text(mood.rawValue)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(mood.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(mood.color.opacity(0.10))
                    .overlay(
                        Capsule()
                            .strokeBorder(mood.color.opacity(0.25), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Mood Variant Extension
extension MoodVariant {
    func forMood(_ mood: Mood) -> String {
        switch mood {
        case .ready:       return ready
        case .overwhelmed: return overwhelmed
        case .lonely:      return lonely
        }
    }
}

// MARK: - Mood Adaptive Section
enum SectionStyle { case briefing, standard }

struct MoodAdaptiveSection: View {
    let label: String
    let icon: String
    let content: String
    let color: Color
    let style: SectionStyle
    let appeared: Bool
    let delay: Double
    
    @EnvironmentObject var moodManager: MoodManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
                
                Spacer()
                
                // Mood indicator pill
                HStack(spacing: 4) {
                    Image(systemName: moodManager.currentMood.icon)
                        .font(.system(size: 9))
                    Text(moodManager.currentMood.rawValue)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                }
                .foregroundColor(moodManager.currentMood.color.opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(moodManager.currentMood.color.opacity(0.10))
                )
            }
            .foregroundColor(color)
            
            if style == .briefing {
                Text(content)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(color.opacity(0.18), lineWidth: 1)
                            )
                    }
            } else {
                Text(content)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

// MARK: - Objective View
struct ObjectiveView: View {
    let objective: String
    let pillarColor: Color
    let appeared: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "scope")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(pillarColor)
            
            Text(objective)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(pillarColor.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(pillarColor.opacity(0.15), lineWidth: 1)
                )
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appeared)
    }
}

// MARK: - Mission Resources
struct MissionResourcesView: View {
    let resources: [MissionResource]
    let pillarColor: Color
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "map")
                    .font(.system(size: 11, weight: .bold))
                Text("RESOURCES")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
            }
            .foregroundColor(pillarColor)
            
            VStack(spacing: 6) {
                ForEach(resources) { resource in
                    HStack(alignment: .top, spacing: 10) {
                        Text(resource.icon)
                            .font(.system(size: 14))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(resource.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(resource.detail)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(2)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.05), value: appeared)
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// MARK: - Win Card
struct WinCardView: View {
    let winText: String
    let xpValue: Int
    let pillarColor: Color
    let onContinue: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                // XP earned
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                    Text("+\(xpValue) XP earned")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(pillarColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(pillarColor.opacity(0.12))
                )
                
                ZStack {
                    Circle()
                        .fill(pillarColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(pillarColor)
                }
                
                Text(winText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
                
                Button(action: onContinue) {
                    Text("See your moment →")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(pillarColor))
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .strokeBorder(pillarColor.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: pillarColor.opacity(0.15), radius: 24, x: 0, y: -8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Fledge Moment
struct FledgeMomentView: View {
    let winText: String
    let pillarColor: Color
    let pillar: Pillar
    let onDismiss: () -> Void
    
    @State private var appeared = false
    @State private var starScale: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            Color("AtmosphereTop").ignoresSafeArea()
            RadialGradient(
                colors: [pillarColor.opacity(0.25), Color("AtmosphereTop")],
                center: .center,
                startRadius: 80,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .strokeBorder(pillarColor.opacity(0.12 - Double(i) * 0.03), lineWidth: 1.5)
                            .frame(
                                width: appeared ? CGFloat(80 + i * 55) : 20,
                                height: appeared ? CGFloat(80 + i * 55) : 20
                            )
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(Double(i) * 0.1), value: appeared)
                    }
                    
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(pillarColor.opacity(0.6))
                            .frame(width: 5, height: 5)
                            .offset(
                                x: appeared ? cos(Double(i) * .pi / 4) * 65 : 0,
                                y: appeared ? sin(Double(i) * .pi / 4) * 65 : 0
                            )
                            .opacity(appeared ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.1), value: appeared)
                    }
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(LinearGradient(
                            colors: [pillarColor.opacity(0.8), pillarColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .scaleEffect(starScale)
                        .shadow(color: pillarColor.opacity(0.5), radius: 24)
                }
                .frame(height: 200)
                
                Text(FledgeMoment.forPillar(pillar))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .padding(.top, 36)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
                
                Text(pillar.rawValue.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(pillarColor)
                    .tracking(2)
                    .padding(.top, 14)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Continue →")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 16).fill(pillarColor))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: appeared)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.05)) {
                starScale = 1.0
                appeared = true
            }
        }
    }
}
// MARK: - Hero
struct MissionHeroView: View {
    let mission: Mission
    let pillarColor: Color
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 32)
                .fill(.thickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(pillarColor.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(pillarColor.opacity(0.18), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: mission.pillar.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(mission.pillar.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
                .foregroundColor(pillarColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(pillarColor.opacity(0.15)))
                
                Text(mission.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color("CardText"))
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(mission.duration)
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundColor(Color("CardSubtext"))
            }
            .frame(maxWidth: .infinity)
            .padding(22)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Section
struct MissionSection: View {
    let icon: String
    let label: String
    let content: String
    let color: Color
    let appeared: Bool
    let delay: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .textCase(.uppercase)
                    .tracking(1.0)
            }
            .foregroundColor(color)
            
            Text(content)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color("CardSubtext"))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

// MARK: - Reveal Move Button
struct RevealMoveButton: View {
    let pillarColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 16))
                Text("Show me what to do")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .foregroundColor(pillarColor)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(pillarColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(pillarColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom Action Button
struct BottomActionButton: View {
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color("Background").opacity(0), Color("Background")],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 48)
            
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                    Text(label)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 16).fill(color))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .background(Color("Background"))
        }
    }
}

// MARK: - Completed Badge
struct CompletedBadge: View {
    let pillarColor: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(pillarColor)
                .font(.system(size: 18))
            Text("Mission complete")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(pillarColor)
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(pillarColor.opacity(0.10))
        )
    }
}



