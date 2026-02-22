//
//  MoodManager.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 21/02/26.
//

import SwiftUI
import Combine

@MainActor
class MoodManager: ObservableObject {
    
    @Published var showMoodCheckIn: Bool = false
    @Published var currentMood: Mood = .ready
    
    @AppStorage("lastMoodCheckIn") private var lastMoodCheckIn: String = ""
    @AppStorage("savedMood") private var savedMood: String = Mood.ready.rawValue
    
    init() {
        if let restored = Mood(rawValue: savedMood) {
            currentMood = restored
        }
    }
    
    func checkDailyMood() {
        let today = Self.todayString()
        if lastMoodCheckIn != today {
            showMoodCheckIn = true
        }
    }
    
    func saveMood(_ mood: Mood) {
        let today = Self.todayString()
        lastMoodCheckIn = today
        savedMood = mood.rawValue
        currentMood = mood
        showMoodCheckIn = false
    }
    
    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
}
