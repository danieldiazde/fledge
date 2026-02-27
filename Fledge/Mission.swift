//
//  Mission.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.

import Foundation
import SwiftData

@Model
final class MoodStepRecord {

    var id: UUID = UUID()
    var moodRaw: String
    var sortOrder: Int
    var number: Int
    var action: String
    var howTo: String
    var tip: String?

    init(mood: Mood, sortOrder: Int, step: MissionStep) {
        self.id        = step.id
        self.moodRaw   = mood.rawValue
        self.sortOrder = sortOrder
        self.number    = step.number
        self.action    = step.action
        self.howTo     = step.howTo
        self.tip       = step.tip
    }

    func toStep() -> MissionStep {
        MissionStep(id: id, number: number, action: action, howTo: howTo, tip: tip)
    }
}

// MARK: - MoodResourceRecord

@Model
final class MoodResourceRecord {
    var id: UUID = UUID()
    var moodRaw: String
    var sortOrder: Int
    var typeRaw: String
    var name: String
    var detail: String
    var url: String?

    init(mood: Mood, sortOrder: Int, resource: MissionResource) {
        self.id        = resource.id
        self.moodRaw   = mood.rawValue
        self.sortOrder = sortOrder
        self.typeRaw   = resource.type.rawValue
        self.name      = resource.name
        self.detail    = resource.detail
        self.url       = resource.url
    }

    func toResource() -> MissionResource? {
        guard let type = ResourceType(rawValue: typeRaw) else { return nil }
        return MissionResource(id: id, type: type, name: name, detail: detail, url: url)
    }
}

// MARK: - Mission

@Model
final class Mission {

    // MARK: Scalar properties

    var id: UUID          = UUID()
    var title: String
    var pillar: Pillar
    var weekNumber: Int
    var tags: [MissionTag]
    var duration: String
    var xpValue: Int
    var isComplete: Bool  = false
    var objective: String
    var prerequisiteMissionID: UUID? = nil

    // MARK: MoodVariant storage — 9 flat strings, zero encoding
    //
    // briefing, truth, and win each need ready / overwhelmed / lonely variants.

    var briefingReady:       String
    var briefingOverwhelmed: String
    var briefingLonely:      String

    var truthReady:          String
    var truthOverwhelmed:    String
    var truthLonely:         String

    var winReady:            String
    var winOverwhelmed:      String
    var winLonely:           String

    // MARK: Progress storage — flat primitives, zero encoding
    //
    // SwiftData stores [UUID] natively, so no serialization needed.

    var progressStartingMoodRaw: String? = nil
    var progressActiveMoodRaw:   String? = nil
    var progressCheckedStepIDs:  [UUID]  = []

    // MARK: Relationships

    @Relationship(deleteRule: .cascade)
    var stepRecords: [MoodStepRecord] = []

    @Relationship(deleteRule: .cascade)
    var resourceRecords: [MoodResourceRecord] = []

    // MARK: - Computed accessors (no encoding — pure struct construction)

    var briefing: MoodVariant {
        get { MoodVariant(ready: briefingReady, overwhelmed: briefingOverwhelmed, lonely: briefingLonely) }
        set { briefingReady = newValue.ready; briefingOverwhelmed = newValue.overwhelmed; briefingLonely = newValue.lonely }
    }

    var truth: MoodVariant {
        get { MoodVariant(ready: truthReady, overwhelmed: truthOverwhelmed, lonely: truthLonely) }
        set { truthReady = newValue.ready; truthOverwhelmed = newValue.overwhelmed; truthLonely = newValue.lonely }
    }

    var win: MoodVariant {
        get { MoodVariant(ready: winReady, overwhelmed: winOverwhelmed, lonely: winLonely) }
        set { winReady = newValue.ready; winOverwhelmed = newValue.overwhelmed; winLonely = newValue.lonely }
    }

    var progress: MissionProgress? {
        get {
            guard
                let startRaw  = progressStartingMoodRaw, let start  = Mood(rawValue: startRaw),
                let activeRaw = progressActiveMoodRaw,   let active = Mood(rawValue: activeRaw)
            else { return nil }
            return MissionProgress(startingMood: start, activeMood: active, checkedStepIds: progressCheckedStepIDs)
        }
        set {
            progressStartingMoodRaw = newValue?.startingMood.rawValue
            progressActiveMoodRaw   = newValue?.activeMood.rawValue
            progressCheckedStepIDs  = newValue?.checkedStepIds ?? []
        }
    }

    // Calls MissionData which is @MainActor — must be @MainActor here too.
    @MainActor
    var prerequisiteTitle: String {
        guard let prereqID = prerequisiteMissionID else { return "" }
        return MissionData.mission(withID: prereqID)?.title ?? ""
    }

    // MARK: - Helpers

    func activeSteps(for mood: Mood) -> [MissionStep] {
        stepRecords
            .filter { $0.moodRaw == mood.rawValue }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map    { $0.toStep() }
    }

    func activeResources(for mood: Mood) -> [MissionResource] {
        resourceRecords
            .filter  { $0.moodRaw == mood.rawValue }
            .sorted  { $0.sortOrder < $1.sortOrder }
            .compactMap { $0.toResource() }
    }
    
    @MainActor
    func completedCount(for mood: Mood) -> Int {
        progress?.completedCount(for: activeSteps(for: mood)) ?? 0
    }
    
    @MainActor
    func allStepsComplete(for mood: Mood) -> Bool {
        progress?.isAllComplete(for: activeSteps(for: mood)) ?? false
    }


    init(
        title: String,
        briefing: MoodVariant,
        truth: MoodVariant,
        win: MoodVariant,
        objective: String,
        moodSteps: MoodSteps,
        moodResources: MoodResources,
        pillar: Pillar,
        weekNumber: Int,
        tags: [MissionTag],
        duration: String,
        xpValue: Int,
        progress: MissionProgress? = nil
    ) {
        self.title      = title
        self.objective  = objective
        self.pillar     = pillar
        self.weekNumber = weekNumber
        self.tags       = tags
        self.duration   = duration
        self.xpValue    = xpValue
        self.isComplete = false

        self.briefingReady       = briefing.ready
        self.briefingOverwhelmed = briefing.overwhelmed
        self.briefingLonely      = briefing.lonely

        self.truthReady          = truth.ready
        self.truthOverwhelmed    = truth.overwhelmed
        self.truthLonely         = truth.lonely

        self.winReady            = win.ready
        self.winOverwhelmed      = win.overwhelmed
        self.winLonely           = win.lonely

        self.progressStartingMoodRaw = progress?.startingMood.rawValue
        self.progressActiveMoodRaw   = progress?.activeMood.rawValue
        self.progressCheckedStepIDs  = progress?.checkedStepIds ?? []
        
        var steps: [MoodStepRecord] = []
        for (i, step) in moodSteps.ready.enumerated()       { steps.append(MoodStepRecord(mood: .ready,       sortOrder: i, step: step)) }
        for (i, step) in moodSteps.overwhelmed.enumerated() { steps.append(MoodStepRecord(mood: .overwhelmed, sortOrder: i, step: step)) }
        for (i, step) in moodSteps.lonely.enumerated()      { steps.append(MoodStepRecord(mood: .lonely,      sortOrder: i, step: step)) }
        self.stepRecords = steps

        var resources: [MoodResourceRecord] = []
        for (i, r) in moodResources.ready.enumerated()       { resources.append(MoodResourceRecord(mood: .ready,       sortOrder: i, resource: r)) }
        for (i, r) in moodResources.overwhelmed.enumerated() { resources.append(MoodResourceRecord(mood: .overwhelmed, sortOrder: i, resource: r)) }
        for (i, r) in moodResources.lonely.enumerated()      { resources.append(MoodResourceRecord(mood: .lonely,      sortOrder: i, resource: r)) }
        self.resourceRecords = resources
    }


    convenience init(
        title: String,
        briefing: MoodVariant,
        truth: MoodVariant,
        objective: String,
        steps: [MissionStep],
        resources: [MissionResource],
        win: MoodVariant,
        pillar: Pillar,
        weekNumber: Int,
        tags: [MissionTag],
        duration: String,
        xpValue: Int
    ) {
        self.init(
            title: title,
            briefing: briefing,
            truth: truth,
            win: win,
            objective: objective,
            moodSteps: MoodSteps(ready: steps, overwhelmed: steps, lonely: steps),
            moodResources: MoodResources(ready: resources, overwhelmed: resources, lonely: resources),
            pillar: pillar,
            weekNumber: weekNumber,
            tags: tags,
            duration: duration,
            xpValue: xpValue
        )
    }
}
