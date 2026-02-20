//
//  OnboardingView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
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
            Color("Background").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    FledgeLogo(isAppeared: appeared)

                    Text("Fledge")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryText"))
                        .opacity(appeared ? 1 : 0)

                    Text("Your first flight, figured out.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryText"))
                        .opacity(appeared ? 1 : 0)
                }

                Spacer()
                Spacer()

                
                VStack(spacing: 36) {
                    
                    VStack(spacing: 8) {
                        Text("When did you arrive?")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SecondaryText"))
                        
                        
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
                        
                        Text(relativeArrivalString)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("SecondaryText"))
                            .contentTransition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: selectedDate)
                    }
                    
                    VStack(spacing: 20) {
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
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color("AccentColor"))
                                )
                                .shadow(color: Color("AccentColor").opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 32)

                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                            Text("Entirely on-device. Your timeline is yours alone.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color("SecondaryText"))
                    }
                }
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
}
