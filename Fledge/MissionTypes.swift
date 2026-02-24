//
//  MissionTypes.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 24/02/26.
//

import Foundation

// MARK: - Mood

enum Mood: String, Codable, CaseIterable, Sendable {
    case ready       = "Ready"
    case overwhelmed = "Overwhelmed"
    case lonely      = "Lonely"
}

// MARK: - Pillar

enum Pillar: String, Codable, CaseIterable, Sendable {
    case city      = "The City"
    case adultMode = "Adult Mode"
    case growth    = "Your Growth"
}

// MARK: - MissionTag

enum MissionTag: String, Codable, CaseIterable, Sendable {
    case city, navigation, exploration, independence, routine
    case adultLife, budget, cooking
    case growth, fitness, wellbeing, social
    case vegetarian, vegan
    case planner, spontaneous
}

// MARK: - ResourceType

enum ResourceType: String, Codable, Sendable {
    case app, place, tip, warning, cost
}

// MARK: - MissionResource

struct MissionResource: Codable, Identifiable, Sendable {
    var id: UUID     = UUID()
    var type: ResourceType
    var name: String
    var detail: String
    var url: String?
    // UI extension (icon) lives in Mission+UI.swift
}

// MARK: - MissionStep

struct MissionStep: Codable, Identifiable, Sendable {
    var id: UUID     = UUID()
    var number: Int
    var action: String
    var howTo: String
    var tip: String?
}

// MARK: - MoodVariant

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

// MARK: - MoodSteps

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

// MARK: - MoodResources

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

// MARK: - MissionProgress

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
