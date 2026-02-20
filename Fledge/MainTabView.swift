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
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if selectedTab == 0 {
                    DashboardView()
                        .environmentObject(arrivalManager)
                        .environmentObject(userProfile)
                } else {
                    SkyView()
                        .environmentObject(arrivalManager)
                        .environmentObject(userProfile)
                }
            }
            
            FledgeTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct FledgeTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: selectedTab == 0 ? "map.fill" : "map",
                label: "Missions",
                isSelected: selectedTab == 0
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            TabBarButton(
                icon: selectedTab == 1 ? "star.fill" : "star",
                label: "Sky",
                isSelected: selectedTab == 1
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color("Background")
                .opacity(0.97)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: -2)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? Color.accentColor : Color("SecondaryText").opacity(0.45))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
