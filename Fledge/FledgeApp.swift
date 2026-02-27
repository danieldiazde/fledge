//
//  FledgeApp.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI
import SwiftData

@main
struct FledgeApp: App {
    @StateObject private var arrivalManager = ArrivalManager()
    @StateObject private var userProfile = UserProfile()
    @StateObject private var moodManager = MoodManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arrivalManager)
                .environmentObject(userProfile)
                .environmentObject(moodManager)
        }
        .modelContainer(for: [Mission.self, MoodStepRecord.self, MoodResourceRecord.self])
    }
}
