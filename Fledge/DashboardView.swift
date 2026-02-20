//
//  DashboardView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI


struct DashboardView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    
    var body: some View {
        VStack {
            Text("Dashboard - Week \(arrivalManager.currentWeek)")
                .font(.system(.title, design: .rounded))
            
            Button("Reset (Testing Only)") {
                arrivalManager.reset()
            }
            .foregroundColor(.red)
        }
    }
}
