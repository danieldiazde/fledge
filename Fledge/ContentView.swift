//
//  ContentView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var arrivalManager = ArrivalManager()
    @StateObject private var userProfile = UserProfile()
    
    var body: some View {
        Group {
            if !arrivalManager.hasSetArrivalDate {
                OnboardingView()
                    .environmentObject(arrivalManager)
                    .environmentObject(userProfile)
            } else if !userProfile.isComplete {
                ProfileSetupView()
                    .environmentObject(arrivalManager)
                    .environmentObject(userProfile)
            } else {
                MainTabView()
                    .environmentObject(arrivalManager)
                    .environmentObject(userProfile)
            }
        }
    }
}

#Preview {
    ContentView()
}
