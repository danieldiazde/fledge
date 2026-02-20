//
//  ContentView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var arrivalManager = ArrivalManager()
    
    var body: some View {
        if arrivalManager.hasSetArrivalDate {
            DashboardView()
                .environmentObject(arrivalManager)
        } else {
            OnboardingView()
                .environmentObject(arrivalManager)
        }
    }
}

#Preview {
    ContentView()
}
