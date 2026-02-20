//
//  ProfileSetupView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var userProfile: UserProfile
    
    @State private var currentQuestion = 0
    @State private var appeared = false
    @State private var transitioning = false
    @State private var showMoment = false
    
    let questions: [ProfileQuestion] = [
        ProfileQuestion(
            number: "01",
            prompt: "What matters most\nto you right now?",
            subtitle: "This shapes your first missions.",
            options: [
                ProfileOption(label: "Staying healthy", icon: "figure.walk", tag: "fitness"),
                ProfileOption(label: "Saving money", icon: "banknote", tag: "budget"),
                ProfileOption(label: "Exploring the city", icon: "map", tag: "city"),
                ProfileOption(label: "Meeting people", icon: "person.2", tag: "social")
            ]
        ),
        ProfileQuestion(
            number: "02",
            prompt: "How do\nyou eat?",
            subtitle: "We'll tailor your cooking missions.",
            options: [
                ProfileOption(label: "Everything", icon: "fork.knife", tag: "omnivore"),
                ProfileOption(label: "Vegetarian", icon: "leaf", tag: "vegetarian"),
                ProfileOption(label: "Vegan", icon: "carrot", tag: "vegan"),
                ProfileOption(label: "I have restrictions", icon: "allergens", tag: "restrictions")
            ]
        ),
        ProfileQuestion(
            number: "03",
            prompt: "How do you tackle\nnew things?",
            subtitle: "This sets your mission pace.",
            options: [
                ProfileOption(label: "I like a clear plan", icon: "list.bullet.clipboard", tag: "planner"),
                ProfileOption(label: "I figure it out as I go", icon: "figure.walk.motion", tag: "spontaneous"),
                ProfileOption(label: "Depends on the day", icon: "sun.horizon", tag: "mixed")
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            if showMoment {
                // Transition screen before dashboard
                ReadyView()
                    .environmentObject(userProfile)
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    
                    // Progress bar
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(i <= currentQuestion ? Color.accentColor : Color.accentColor.opacity(0.2))
                                .frame(height: 4)
                                .animation(.spring(response: 0.4), value: currentQuestion)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Question
                    VStack(alignment: .leading, spacing: 12) {
                        Text(questions[currentQuestion].number)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color.accentColor)
                            .tracking(2)
                        
                        Text(questions[currentQuestion].prompt)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryText"))
                            .lineSpacing(4)
                        
                        Text(questions[currentQuestion].subtitle)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color("SecondaryText"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    
                    Spacer()
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(Array(questions[currentQuestion].options.enumerated()), id: \.offset) { index, option in
                            OptionButton(
                                option: option,
                                delay: Double(index) * 0.08
                            ) {
                                selectOption(option.label)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
    
    func selectOption(_ label: String) {
        // Save answer
        switch currentQuestion {
        case 0: userProfile.goal = label
        case 1: userProfile.diet = label
        case 2: userProfile.style = label
        default: break
        }
        
        
        if currentQuestion < 2 {
            // Animate to next question
            withAnimation(.easeInOut(duration: 0.25)) {
                appeared = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentQuestion += 1
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        } else {
            // All done — show ready screen
            withAnimation(.easeInOut(duration: 0.4)) {
                showMoment = true
            }
        }
    }
}

// MARK: - Supporting Types
struct ProfileQuestion {
    let number: String
    let prompt: String
    let subtitle: String
    let options: [ProfileOption]
}

struct ProfileOption {
    let label: String
    let icon: String
    let tag: String
}

// MARK: - Option Button
struct OptionButton: View {
    let option: ProfileOption
    let delay: Double
    let action: () -> Void
    
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: option.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color.accentColor)
                }
                
                Text(option.label)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("SecondaryText").opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("CardBackground"))
                    .shadow(color: Color.black.opacity(isPressed ? 0.02 : 0.06), radius: isPressed ? 4 : 12, x: 0, y: isPressed ? 1 : 4)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                }
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Ready View
struct ReadyView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var appeared = false
    
    var headline: String {
        switch userProfile.goal {
        case "Staying healthy": return "Let's keep you\nstrong out there."
        case "Saving money": return "Let's make every\neurocent count."
        case "Exploring the city": return "There's a whole\ncity waiting for you."
        case "Meeting people": return "You're about to\nmeet your people."
        default: return "Your journey\nstarts now."
        }
    }
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Animated logo
                    FledgeLogo(isAppeared: appeared)
                    
                    Text(headline)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryText"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    
                    Text("Your missions are ready.")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(Color("SecondaryText"))
                        .opacity(appeared ? 1 : 0)
                }
                
                Spacer()
                
                // CTA
                Button {
                    // Mark profile as complete by setting a flag
                    // userProfile.isComplete is already true at this point
                    // We just need ContentView to re-evaluate
                    userProfile.style = userProfile.style // triggers objectWillChange
                } label: {
                    Text("I'm ready →")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.accentColor)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
                appeared = true
            }
        }
    }
}
