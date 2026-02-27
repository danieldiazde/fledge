//
//  ProfileSetupView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentQuestion = 0
    @State private var appeared = false
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
            // Atmospheric background
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.accentColor.opacity(0.08), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()
            
            if showMoment {
                ReadyView()
                    .environmentObject(userProfile)
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    
                    // Progress pills
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(i <= currentQuestion
                                    ? Color.accentColor
                                    : Color.primary.opacity(0.12)
                                )
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
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color.accentColor)
                            .tracking(2)
                        
                        Text(questions[currentQuestion].prompt)
                            .font(.system(.title, design: .rounded)) // Fixed typo from .title1
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        Text(questions[currentQuestion].subtitle)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    
                    Spacer()
                    
                    // Options
                    VStack(spacing: 10) {
                        ForEach(Array(questions[currentQuestion].options.enumerated()), id: \.offset) { index, option in
                            ProfileOptionButton(
                                option: option,
                                delay: Double(index) * 0.07
                            ) {
                                selectOption(option.label)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: currentQuestion)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
    
    func selectOption(_ label: String) {
        switch currentQuestion {
        case 0: userProfile.goal = label
        case 1: userProfile.diet = label
        case 2: userProfile.style = label
        default: break
        }
        
        if currentQuestion < 2 {
            withAnimation(.easeInOut(duration: 0.2)) { appeared = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                currentQuestion += 1
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.4)) {
                showMoment = true
            }
        }
    }
}

// MARK: - Profile Option Button
struct ProfileOptionButton: View {
    let option: ProfileOption
    let delay: Double
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.accentColor.opacity(0.20), lineWidth: 1)
                        )
                    
                    Image(systemName: option.icon)
                        .font(.system(.title2))
                        .foregroundColor(Color.accentColor)
                }
                
                Text(option.label)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(.subheadline))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.07)
                                    : Color.black.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05),
                        radius: 8, x: 0, y: 3
                    )
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
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

// MARK: - Ready View
struct ReadyView: View {
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.colorScheme) var colorScheme
    @State private var appeared = false
    @State private var commitProfile = false
    
    var headline: String {
        let name = userProfile.name.isEmpty ? "" : ", \(userProfile.name)"
        switch userProfile.goal {
        case "Staying healthy": return "Let's keep you\nstrong out there\(name)."
        case "Saving money":    return "Let's make every\npeso count\(name)."
        case "Exploring the city": return "There's a whole\ncity waiting for you."
        case "Meeting people":  return "You're about to\nmeet your people."
        default:                return "Your journey\nstarts now."
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.accentColor.opacity(0.12), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                            .frame(width: 110, height: 110)
                            .shadow(
                                color: Color.accentColor.opacity(0.15),
                                radius: 20, x: 0, y: 8
                            )
                        
                    }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.7)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
                    
                    VStack(spacing: 10) {
                        Text(headline)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("Your missions are ready.")
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
                }
                
                Spacer()
                
                Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            commitProfile = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            userProfile.style = userProfile.style
                        }
                    } label: {
                        
                        Group {
                           if commitProfile {
                               ProgressView()
                                 .tint(.white)
                           } else {
                               Text("I'm ready →")
                           }
                        }
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
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
                .disabled(commitProfile)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .scaleEffect(commitProfile ? 0.95 : 1.0)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: appeared)
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: commitProfile)
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
        
    }
}
