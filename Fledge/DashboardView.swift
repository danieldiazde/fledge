//
//  DashboardView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    
    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.system(.title, design: .rounded))
            
            // TEMP
            Button("Reset (Testing Only)") {
                UserDefaults.standard.removeObject(forKey: "arrivalDate")
                arrivalManager.arrivalDate = Date()
                userProfile.reset()
            }
            .foregroundColor(.red)
        }
    }
}
