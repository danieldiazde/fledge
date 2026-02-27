//
//  MissionStore.swift
//  Fledge

import Foundation

enum MissionStore {

    // MARK: - Keys

    private static func completedKey(_ mission: Mission) -> String {
        "fledge.mission.complete.\(mission.title)"
    }

    private static func progressKey(_ mission: Mission) -> String {
        "fledge.mission.progress.\(mission.title)"
    }

    // MARK: - Save

    static func save(_ mission: Mission) {
        let ud = UserDefaults.standard
        ud.set(mission.isComplete, forKey: completedKey(mission))

        if let progress = mission.progress,
           let encoded = try? JSONEncoder().encode(progress) {
            ud.set(encoded, forKey: progressKey(mission))
        } else {
            ud.removeObject(forKey: progressKey(mission))
        }
    }

    // MARK: - Restore

    static func restore(_ mission: Mission) {
        let ud = UserDefaults.standard

        if ud.bool(forKey: completedKey(mission)) {
            mission.isComplete = true
        }

        if let data = ud.data(forKey: progressKey(mission)),
           let progress = try? JSONDecoder().decode(MissionProgress.self, from: data) {
            mission.progress = progress
        }
    }

    // MARK: - Reset (for testing / onboarding reset)

    static func resetAll() {
        let ud = UserDefaults.standard
        let prefix = "fledge.mission."
        ud.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(prefix) }
            .forEach { ud.removeObject(forKey: $0) }
    }
}
