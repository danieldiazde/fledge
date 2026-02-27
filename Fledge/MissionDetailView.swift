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
                    
                    if isLocked {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .font(.system(.footnote))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mission locked")
                                    .font(.system(.footnote, design: .rounded))
                                    .fontWeight(.bold)
                                Text("Complete \"\(prerequisiteTitle)\" first")
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
                    
                    // Briefing
                    MoodAdaptiveSection(
                        label: "BRIEFING",
                        icon: "bolt.fill",
                        content: mission.briefing.text(for: activeMood)
                            .personalized(name: userProfile.name, city: userProfile.city),
                        color: pillarColor,
                        style: .briefing,
                        appeared: appeared,
                        delay: 0.10
                    )
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                    
                    // Objective
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
                    
                    // Truth
                    MoodAdaptiveSection(
                        label: "THE TRUTH",
                        icon: "quote.opening",
                        content: mission.truth.text(for: activeMood)
                            .personalized(name: userProfile.name, city: userProfile.city),
                        color: pillarColor,
                        style: .standard,
                        appeared: appeared,
                        delay: 0.20
                    )
                    .padding(.top, 28)
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
                                MissionStore.save(mission)
                            }
                        )
                        .padding(.top, 36)
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
                        .padding(.top, 32)
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
                            userProfile.totalXP += mission.xpValue
                        }
                        #if os(iOS)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        }
                        #endif
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
                    winText: mission.win.text(for: activeMood)
                        .personalized(name: userProfile.name, city: userProfile.city),
                    xpValue: mission.xpValue,
                    pillarColor: pillarColor
                ) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        mission.isComplete = true
                        showMoment = true
                    }
                    MissionStore.save(mission)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(9)
            }
            
            // Fledge moment
            if showMoment {
                FledgeMomentView(
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
        .sensoryFeedback(.success, trigger: justCompleted)
        .sensoryFeedback(.impact(weight: .heavy), trigger: activeMood)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(.subheadline))
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
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
                    MissionStore.save(mission)
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
        VStack(alignment: .leading, spacing: 20) {

            // Header
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Steps")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(completedCount) of \(steps.count)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }

                // Progress bar
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
            }

            // Step rows
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
    let autoExpand: Bool
    let onToggle: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Header row
            HStack(alignment: .center, spacing: 14) {

                // Checkbox — isolated button
                Button(action: {
                    onToggle()
                }) {
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
                                .font(.system(.caption2))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Text("\(step.number)")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                    .animation(.spring(response: 0.3), value: isChecked)
                }
                .buttonStyle(.plain)

                // Title + chevron — tap to expand
                HStack(spacing: 8) {
                    Text(step.action)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(isChecked ? .secondary : .primary)
                        .strikethrough(isChecked, color: .secondary.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(.caption2))
                        .fontWeight(.semibold)
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // MARK: Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {

                    // Divider
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
                            Text(tip)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundColor(pillarColor.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(3)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(pillarColor.opacity(0.08))
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 14)
                .transition(.opacity)
            }
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
        .onAppear {
            isExpanded = autoExpand
        }
        .sensoryFeedback(isChecked ? .impact(weight: .medium) : .impact(weight: .light), trigger: isChecked)
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
   

    @Environment(\.colorScheme) var colorScheme
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
                        .font(.system(.caption2))
                    Text("\(xpValue) XP on completion")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(pillarColor.opacity(0.7))
                
                Button(action: onComplete) {
                    HStack(spacing: 10) {
                        Image(systemName: allStepsComplete ? "checkmark" : "lock.fill")
                            .font(.system(.headline))
                            .fontWeight(.bold)
                        Text(allStepsComplete ? "Mission Complete" : "Complete all steps first")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
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
                        .font(.system(.subheadline))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    MoodPill(mood: currentMood, label: "Today")
                }
                .padding(.top, 8)
                
                VStack(spacing: 8) {
                    Text("You're feeling different today.")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
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
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
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

// MARK: - Mood Pill

struct MoodPill: View {
    let mood: Mood
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .tracking(1)
            
            HStack(spacing: 5) {
                Image(systemName: mood.icon)
                    .font(.system(.caption2))
                Text(mood.rawValue)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
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
        Group {
            if style == .briefing {
                // Blockquote style — the emotional hook
                HStack(alignment: .top, spacing: 16) {
                    // Left accent bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 3)
                        .padding(.vertical, 2)

                    Text(content)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)

            } else {
                // Pull quote style — editorial, thoughtful
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: "quote.opening")
                        .font(.system(.title2))
                        .fontWeight(.bold)
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "scope")
                .font(.system(.subheadline))
                .fontWeight(.semibold)
                .foregroundColor(pillarColor)
                .padding(.top, 1)

            Text(objective)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
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
        VStack(alignment: .leading, spacing: 20) {

            // Header
            Text("Resources")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)

            VStack(spacing: 12) {
                ForEach(resources) { resource in
                    HStack(alignment: .top, spacing: 14) {

                        // Icon
                        Text(resource.icon)
                            .font(.system(.title3))
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primary.opacity(0.05))
                            )

                        // Text
                        VStack(alignment: .leading, spacing: 5) {
                            Text(resource.name)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
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
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(Double(resources.firstIndex(where: { $0.id == resource.id }) ?? 0) * 0.06), value: appeared)
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
    
    @State private var checkmarkScale: CGFloat = 0.001
    @State private var particlesBurst = false
    @State private var displayedXP = 0
    @State private var glowPulse = false
    
    let particleCount = 12
    func particleAngle(_ index: Int) -> Double { Double(index) * (360.0 / Double(particleCount)) }
    func particleRadius(_ index: Int) -> CGFloat { index % 2 == 0 ? 55 : 38 }
    func particleSize(_ index: Int) -> CGFloat { index % 3 == 0 ? 7 : 5 }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                
                // ── Checkmark + particle burst ──────────────────────────────
                ZStack {
                    // Particles — burst outward on appear
                    ForEach(0..<particleCount, id: \.self) { i in
                        let angle = particleAngle(i) * .pi / 180.0
                        let radius = particleRadius(i)
                        Circle()
                            .fill(pillarColor.opacity(0.70))
                            .frame(width: particleSize(i), height: particleSize(i))
                            .offset(
                                x: particlesBurst ? cos(angle) * radius : 0,
                                y: particlesBurst ? sin(angle) * radius : 0
                            )
                            .opacity(particlesBurst ? 0 : 1)
                            .animation(
                                .spring(response: 0.55, dampingFraction: 0.62)
                                .delay(0.20 + Double(i) * 0.018), value: particlesBurst
                            )
                    }
                    
                    // Outer glow ring — breathes
                    Circle()
                        .fill(pillarColor.opacity(glowPulse ? 0.22 : 0.07))
                        .frame(width: 96, height: 96)
                        .blur(radius: 14)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)
                    
                    // Glass circle
                    Circle()
                        .fill(pillarColor.opacity(0.15))
                        .frame(width: 72, height: 72)
                        .overlay(Circle().strokeBorder(pillarColor.opacity(0.30), lineWidth: 1.5))
                    
                    // Checkmark — springs in
                    Image(systemName: "checkmark")
                        .font(.system(.title2))
                        .fontWeight(.bold)
                        .foregroundColor(pillarColor)
                        .scaleEffect(checkmarkScale)
                        .animation(
                            .spring(response: 0.50, dampingFraction: 0.55).delay(0.10),
                            value: checkmarkScale
                        )
                }
                .padding(.top, 10)
                
                // ── XP Earned (counts up) ───────────────────────────────────
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(.subheadline))
                    Text("+\(displayedXP) XP earned")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .contentTransition(.numericText(value: Double(displayedXP)))
                }
                .foregroundColor(pillarColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(pillarColor.opacity(0.12)))
                .padding(.top, -4)
                
                // ── Win Text ────────────────────────────────────────────────
                Text(winText)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
                
                // ── Button ──────────────────────────────────────────────────
                Button(action: onContinue) {
                    Text("See your moment →")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(pillarColor))
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
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
        .onAppear {
            // Checkmark spring
            withAnimation {
                checkmarkScale = 1.0
            }
            // Particle burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                particlesBurst = true
            }
            // XP counter
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.85)) {
                    displayedXP = xpValue
                }
            }
            // Glow pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                withAnimation {
                    glowPulse = true
                }
            }
        }
    }
}

// MARK: - Fledge Moment
struct FledgeMomentView: View {
    let pillarColor: Color
    let pillar: Pillar
    let onDismiss: () -> Void
    
    @EnvironmentObject var moodManager: MoodManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var appeared = false
    @State private var starScale: CGFloat = 0.3
    @State private var glowPulse = false
    
    var body: some View {
        ZStack {
            // ── Mood-reactive sky (matches dashboard exactly) ───────────────
            LinearGradient(
                colors: colorScheme == .dark
                    ? moodManager.currentMood.atmosphereColors
                    : moodManager.currentMood.lightModeAtmosphereColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Pillar radial glow
            RadialGradient(
                colors: [pillarColor.opacity(colorScheme == .dark ? 0.30 : 0.15), Color.clear],
                center: .center,
                startRadius: 60,
                endRadius: 520
            )
            .ignoresSafeArea()
            
            // ── Starfield (dark mode only — same Canvas technique as SkyView) ─
            if colorScheme == .dark {
                TimelineView(.animation) { timeline in
                    Canvas { ctx, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        for i in 1...30 {
                            let x  = CGFloat((i * 73  + 11) % 100) / 100.0 * size.width
                            let y  = CGFloat((i * 89  + 31) % 100) / 100.0 * size.height
                            let tw = (sin(t * Double(i % 7 + 1) * 0.45 + Double(i) * 0.9) + 1.0) / 2.0
                            let r: CGFloat = i % 5 == 0 ? 1.6 : (i % 3 == 0 ? 1.1 : 0.7)
                            let alpha = 0.08 + 0.20 * tw
                            ctx.fill(
                                Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                                with: .color(.white.opacity(alpha))
                            )
                        }
                    }
                }
                .ignoresSafeArea()
            }
            
            // ── Content ──────────────────────────────────────────────────────
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    // Expanding concentric rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .strokeBorder(pillarColor.opacity(0.18 - Double(i) * 0.05), lineWidth: 1.5)
                            .frame(
                                width: appeared ? CGFloat(80 + i * 65) : 20,
                                height: appeared ? CGFloat(80 + i * 65) : 20
                            )
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(Double(i) * 0.1), value: appeared)
                    }
                    
                    // Floating dots
                    ForEach(0..<8, id: \.self) { i in
                        let angle = Double(i) * .pi / 4
                        Circle()
                            .fill(pillarColor.opacity(0.65))
                            .frame(width: 6, height: 6)
                            .offset(
                                x: appeared ? cos(angle) * 72 : 0,
                                y: appeared ? sin(angle) * 72 : 0
                            )
                            .opacity(appeared ? 1 : 0)
                            .animation(
                                .spring(response: 0.55, dampingFraction: 0.52).delay(0.12), value: appeared
                            )
                    }
                    
                    // Outer glow halo
                    Circle()
                        .fill(pillarColor.opacity(glowPulse ? 0.20 : 0.06))
                        .frame(width: 130, height: 130)
                        .blur(radius: 24)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)
                    
                    // Main checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [pillarColor.opacity(0.85), pillarColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(starScale)
                        .shadow(color: pillarColor.opacity(0.55), radius: 28)
                }
                .frame(height: 220)
                
                // Moment text
                Text(FledgeMoment.forPillar(pillar))
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .padding(.top, 42)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
                
                // Pillar tag
                Text(pillar.rawValue.uppercased())
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(pillarColor)
                    .tracking(2)
                    .padding(.top, 14)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Continue →")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation { glowPulse = true }
            }
        }
    }
}
// MARK: - Hero
struct MissionHeroView: View {
    let mission: Mission
    let pillarColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Pillar pill — small, subtle
            HStack(spacing: 6) {
                Image(systemName: mission.pillar.icon)
                    .font(.system(.caption2))
                    .fontWeight(.semibold)
                Text(mission.pillar.rawValue)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            .foregroundColor(pillarColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(pillarColor.opacity(0.12)))

            // Title — large, breathing, no box
            Text(mission.title)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Duration
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(.caption))
                Text(mission.duration)
                    .font(.system(.subheadline, design: .rounded))
            }
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
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
                    .font(.system(.caption))
                    .fontWeight(.semibold)
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .tracking(1.0)
            }
            .foregroundColor(color)
            
            Text(content)
                .font(.system(.callout, design: .rounded))
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
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ready to move?")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("See the steps for this mission")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(.title))
                    .foregroundColor(pillarColor)
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
                        .font(.system(.subheadline))
                        .fontWeight(.bold)
                    Text(label)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
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
                .font(.system(.title3))
            Text("Mission complete")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
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
