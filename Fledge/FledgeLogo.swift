//
//  FledgeLogo.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//
import SwiftUI

struct FledgeLogo: View {
    var isAppeared: Bool

    @State private var isFloating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("Background"))
                .frame(width: 96, height: 96)
                .shadow(color: Color("AccentColor").opacity(0.15), radius: 10, x: 0, y: 5)
            
            Image(systemName: "bird.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("AccentColor").opacity(0.8), Color("AccentColor")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(y: isFloating ? -3 : 3)
        }

        .opacity(isAppeared ? 1 : 0)
        .scaleEffect(isAppeared ? 1 : 0.6)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAppeared)
        
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
}
