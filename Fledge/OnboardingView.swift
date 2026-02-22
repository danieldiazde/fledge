//
//  OnboardingView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate = Date()
    @State private var appeared = false
    
    var allowedDateRange: ClosedRange<Date> {
        let today = Date()
        let fourWeeksAgo = Calendar.current.date(byAdding: .day, value: -28, to: today)!
        return fourWeeksAgo...today
    }
    
    var relativeArrivalString: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        let text = formatter.localizedString(for: selectedDate, relativeTo: Date())
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    var body: some View {
        ZStack {
            // Atmospheric background
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle accent glow from top
            RadialGradient(
                colors: [Color.accentColor.opacity(0.10), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: Logo + Title
                VStack(spacing: 20) {
                    // Constellation logo
                    ZStack {
                        // Frosted backing circle
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                            )
                            .frame(width: 110, height: 110)
                            .shadow(
                                color: Color.accentColor.opacity(0.20),
                                radius: 24, x: 0, y: 8
                            )
                        
                        FledgeLogo(isAppeared: appeared, size: 80)
                    }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.7)
                    
                    VStack(spacing: 8) {
                        Text("Fledge")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Your first flight, figured out.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                }
                
                Spacer()
                Spacer()
                
                // MARK: Date picker glass card
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("When did you arrive?")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        #if os(iOS)
                        DatePicker(
                            "Arrival date",
                            selection: $selectedDate,
                            in: allowedDateRange,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        #else
                        DatePicker(
                            "Arrival date",
                            selection: $selectedDate,
                            in: allowedDateRange,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        #endif
                        
                        // Relative date pill
                        Text(relativeArrivalString)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.accentColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.06))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.accentColor.opacity(0.20), lineWidth: 1)
                                    )
                            )
                            .contentTransition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: selectedDate)
                    }
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(colorScheme == .dark
                                ? AnyShapeStyle(.ultraThinMaterial)
                                : AnyShapeStyle(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .strokeBorder(
                                        colorScheme == .dark
                                            ? Color.white.opacity(0.07)
                                            : Color.black.opacity(0.07),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: Color.black.opacity(colorScheme == .dark ? 0 : 0.06),
                                radius: 12, x: 0, y: 4
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: CTA
                    VStack(spacing: 14) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                arrivalManager.completeOnboarding(with: selectedDate)
                            }
                        } label: {
                            Text("Let's go →")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.accentColor)
                                        .shadow(
                                            color: Color.accentColor.opacity(0.35),
                                            radius: 12, x: 0, y: 5
                                        )
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        // Privacy note
                        HStack(spacing: 5) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("Entirely on-device. Your timeline is yours alone.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                appeared = true
            }
        }
    }
}
