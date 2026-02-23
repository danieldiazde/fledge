//
//  Mission.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//
import Foundation
import SwiftUI
import SwiftData

// MARK: - Mood Enum & UI Extensions

enum Mood: String, Codable, CaseIterable, Sendable {
    case ready = "Ready"
    case overwhelmed = "Overwhelmed"
    case lonely = "Lonely"
    
    // UI Properties centralized here so all views can use them!
    var icon: String {
        switch self {
        case .overwhelmed: return "cloud.drizzle"
        case .lonely: return "moon.stars"
        case .ready: return "wind"
        }
    }
    
    var subtitle: String {
        switch self {
        case .overwhelmed: return "A lot is happening right now."
        case .lonely: return "Missing people or feeling distant."
        case .ready: return "Energized and up for it."
        }
    }
    
    var color: Color {
        switch self {
        case .overwhelmed: return Color(red: 0.45, green: 0.55, blue: 0.85)
        case .lonely: return Color(red: 0.75, green: 0.55, blue: 0.35)
        case .ready: return Color.accentColor
        }
    }
    
    var lightModeColor: Color {
        switch self {
        case .overwhelmed: return Color(red: 0.22, green: 0.32, blue: 0.65)
        case .lonely: return Color(red: 0.58, green: 0.32, blue: 0.15)
        case .ready: return Color(red: 0.72, green: 0.32, blue: 0.20)
        }
    }
    
    var atmosphereColors: [Color] {
        switch self {
        case .overwhelmed: return [
            Color(red: 0.06, green: 0.08, blue: 0.22),
            Color(red: 0.08, green: 0.06, blue: 0.18)
        ]
        case .lonely: return [
            Color(red: 0.16, green: 0.08, blue: 0.06),
            Color(red: 0.12, green: 0.06, blue: 0.08)
        ]
        case .ready: return [
            Color(red: 0.12, green: 0.06, blue: 0.06),
            Color(red: 0.18, green: 0.08, blue: 0.04)
        ]
        }
    }
}

// MARK: - Pillar

enum Pillar: String, Codable, CaseIterable, Sendable {
    case city = "The City"
    case adultMode = "Adult Mode"
    case growth = "Your Growth"
    
    var icon: String {
        switch self {
        case .city:       return "map"
        case .adultMode:  return "wrench.and.screwdriver"
        case .growth:     return "leaf"
        }
    }
}

// MARK: - Resource & Steps

enum ResourceType: String, Codable, Sendable {
    case app, place, tip, warning, cost
    
    var icon: String {
        switch self {
        case .app:     return "📱"
        case .place:   return "📍"
        case .tip:     return "💡"
        case .warning: return "⚠️"
        case .cost:    return "💰"
        }
    }
}

struct MissionResource: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var type: ResourceType
    var name: String
    var detail: String
    var url: String?
    var icon: String { type.icon }
}

struct MissionStep: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var number: Int
    var action: String
    var howTo: String
    var tip: String?
}

// MARK: - Mood Variants

struct MoodVariant: Codable, Sendable {
    var ready: String
    var overwhelmed: String
    var lonely: String
    
    func text(for mood: Mood) -> String {
        switch mood {
        case .ready:       return ready
        case .overwhelmed: return overwhelmed
        case .lonely:      return lonely
        }
    }
}

struct MoodSteps: Codable, Sendable {
    var ready: [MissionStep]
    var overwhelmed: [MissionStep]
    var lonely: [MissionStep]
    
    func steps(for mood: Mood) -> [MissionStep] {
        switch mood {
        case .ready:       return ready
        case .overwhelmed: return overwhelmed
        case .lonely:      return lonely
        }
    }
}

struct MoodResources: Codable, Sendable {
    var ready: [MissionResource]
    var overwhelmed: [MissionResource]
    var lonely: [MissionResource]
    
    func resources(for mood: Mood) -> [MissionResource] {
        switch mood {
        case .ready:       return ready
        case .overwhelmed: return overwhelmed
        case .lonely:      return lonely
        }
    }
}

// MARK: - Progress

struct MissionProgress: Codable, Sendable {
    var startingMood: Mood
    var activeMood: Mood
    var checkedStepIds: [UUID] = []
    
    func isChecked(_ id: UUID) -> Bool {
        checkedStepIds.contains(id)
    }
    
    mutating func toggle(_ id: UUID) {
        if let index = checkedStepIds.firstIndex(of: id) {
            checkedStepIds.remove(at: index)
        } else {
            checkedStepIds.append(id)
        }
    }
    
    func completedCount(for steps: [MissionStep]) -> Int {
        steps.filter { isChecked($0.id) }.count
    }
    
    func isAllComplete(for steps: [MissionStep]) -> Bool {
        !steps.isEmpty && completedCount(for: steps) == steps.count
    }
}

// MARK: - The Mission Model

@Model
class Mission {
    var id: UUID = UUID()
    var title: String
    var pillar: Pillar
    var weekNumber: Int
    var tags: [String]
    var duration: String
    var xpValue: Int
    var isComplete: Bool = false
    var prerequisiteMissionID: UUID? = nil
    var objective: String
    var prerequisiteTitle: String {
        guard let prereqID = prerequisiteMissionID else { return "" }
        return MissionData.mission(withID: prereqID)?.title ?? ""
    }
    
    // 1. SWIFTDATA BUG WORKAROUND: Store as raw Data
    var briefingData: Data
    var truthData: Data
    var winData: Data
    var moodStepsData: Data
    var moodResourcesData: Data
    var progressData: Data?
    
    // 2. TRANSIENT PROPERTIES: Your views use these cleanly!
    // @Transient tells SwiftData to ignore these properties and just let us handle them.
    @Transient var briefing: MoodVariant {
        get { decode(briefingData) ?? MoodVariant(ready: "", overwhelmed: "", lonely: "") }
        set { briefingData = encode(newValue) }
    }
    
    @Transient var truth: MoodVariant {
        get { decode(truthData) ?? MoodVariant(ready: "", overwhelmed: "", lonely: "") }
        set { truthData = encode(newValue) }
    }
    
    @Transient var win: MoodVariant {
        get { decode(winData) ?? MoodVariant(ready: "", overwhelmed: "", lonely: "") }
        set { winData = encode(newValue) }
    }
    
    @Transient var moodSteps: MoodSteps {
        get { decode(moodStepsData) ?? MoodSteps(ready: [], overwhelmed: [], lonely: []) }
        set { moodStepsData = encode(newValue) }
    }
    
    @Transient var moodResources: MoodResources {
        get { decode(moodResourcesData) ?? MoodResources(ready: [], overwhelmed: [], lonely: []) }
        set { moodResourcesData = encode(newValue) }
    }
    
    @Transient var progress: MissionProgress? {
        get { decode(progressData) }
        set { progressData = encode(newValue) }
    }
    
    // MARK: Helpers
    
    func activeSteps(for mood: Mood) -> [MissionStep] {
        moodSteps.steps(for: mood)
    }
    
    func activeResources(for mood: Mood) -> [MissionResource] {
        moodResources.resources(for: mood)
    }
    
    func completedCount(for mood: Mood) -> Int {
        progress?.completedCount(for: activeSteps(for: mood)) ?? 0
    }
    
    func allStepsComplete(for mood: Mood) -> Bool {
        progress?.isAllComplete(for: activeSteps(for: mood)) ?? false
    }
    
    // MARK: Main Init
    
    init(
        title: String,
        briefing: MoodVariant,
        truth: MoodVariant,
        objective: String,
        moodSteps: MoodSteps,
        moodResources: MoodResources,
        win: MoodVariant,
        pillar: Pillar,
        weekNumber: Int,
        tags: [String],
        duration: String,
        xpValue: Int,
        progress: MissionProgress? = nil
    ) {
        self.isComplete = false
        self.progressData = progress != nil
            ? (try? JSONEncoder().encode(progress)) : nil
        
        self.title = title
        self.objective = objective
        self.pillar = pillar
        self.weekNumber = weekNumber
        self.tags = tags
        self.duration = duration
        self.xpValue = xpValue
        
        // Encode directly to bypass the SwiftData crash
        self.briefingData = (try? JSONEncoder().encode(briefing)) ?? Data()
        self.truthData = (try? JSONEncoder().encode(truth)) ?? Data()
        self.winData = (try? JSONEncoder().encode(win)) ?? Data()
        self.moodStepsData = (try? JSONEncoder().encode(moodSteps)) ?? Data()
        self.moodResourcesData = (try? JSONEncoder().encode(moodResources)) ?? Data()
    }
    
    // MARK: Convenience Init (For MissionData.swift)
    
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
        tags: [String],
        duration: String,
        xpValue: Int
    ) {
        self.init(
            title: title,
            briefing: briefing,
            truth: truth,
            objective: objective,
            moodSteps: MoodSteps(ready: steps, overwhelmed: steps, lonely: steps),
            moodResources: MoodResources(ready: resources, overwhelmed: resources, lonely: resources),
            win: win,
            pillar: pillar,
            weekNumber: weekNumber,
            tags: tags,
            duration: duration,
            xpValue: xpValue
        )
    }
    
    
    private func encode<T: Encodable>(_ value: T?) -> Data {
        guard let value = value else { return Data() }
        return (try? JSONEncoder().encode(value)) ?? Data()
    }
    
    private func decode<T: Decodable>(_ data: Data?) -> T? {
        guard let data = data, !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
