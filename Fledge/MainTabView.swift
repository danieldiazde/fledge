//
//  MainTabView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var moodManager: MoodManager
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(arrivalManager)
                .environmentObject(userProfile)
                .environmentObject(moodManager)
                .tabItem {
                    Label("Missions", systemImage: "map")
                }
            
            SkyView()
                .environmentObject(arrivalManager)
                .environmentObject(userProfile)
                .tabItem {
                    Label("The Sky", systemImage: "star")
                }
        }
        .tint(Color.accentColor)
        #if os(iOS)
        .fullScreenCover(isPresented: $moodManager.showMoodCheckIn) {
            MoodCheckInView { mood in
                moodManager.saveMood(mood)
            }
        }
        #endif
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    moodManager.checkDailyMood()
                }
        }
    }
}
