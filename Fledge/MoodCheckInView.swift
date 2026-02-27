//
//  MoodCheckInView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 21/02/26.
//

import SwiftUI

struct MoodCheckInView: View {
    @Environment(\.colorScheme) var colorScheme
    let onComplete: (Mood) -> Void
    
    @State private var selectedMood: Mood? = nil
    @State private var appeared = false
    @State private var confirming = false
    
    private var backgroundColors: [Color] {
            if let mood = selectedMood, colorScheme == .dark {
                return mood.atmosphereColors
            }
            return [Color("AtmosphereTop"), Color("AtmosphereBottom")]
        }
    
    var body: some View {
        ZStack {
            LinearGradient(
                            colors: backgroundColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.5), value: selectedMood?.rawValue)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: selectedMood?.rawValue)
            
            if let mood = selectedMood, colorScheme == .dark {
                RadialGradient(
                    colors: [mood.color.opacity(0.15), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: selectedMood?.rawValue)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Header
                VStack(spacing: 10) {
                    Text("How are you feeling")
                        .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("about today?")
                        .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Fledge will adjust to match.")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                // Mood cards
                VStack(spacing: 12) {
                    ForEach(Array(Mood.allCases.enumerated()), id: \.element.rawValue) { index, mood in
                        MoodCard(
                            mood: mood,
                            isSelected: selectedMood == mood,
                            appeared: appeared,
                            delay: Double(index) * 0.08
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedMood = mood
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue button
                Button {
                    if let mood = selectedMood {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            confirming = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onComplete(mood)
                        }
                    }
                } label: {
                    Text(selectedMood == nil ? "Pick how you're feeling" : "Let's go →")
                        .font(.system(.title3, design: .rounded)) // FIXED: Removed weight from here
                        .fontWeight(.bold)                         // FIXED: Added weight modifier
                        .foregroundColor(selectedMood == nil ? .secondary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedMood == nil
                                    ? AnyShapeStyle(Color.primary.opacity(0.06))
                                    : AnyShapeStyle(
                                        colorScheme == .dark
                                            ? selectedMood!.color
                                            : selectedMood!.lightModeColor
                                    )
                                )
                        }
                }
                .disabled(selectedMood == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.4), value: selectedMood?.rawValue)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                appeared = true
            }
        }
    }
}

// MARK: - Mood Card
struct MoodCard: View {
    let mood: Mood
    let isSelected: Bool
    let appeared: Bool
    let delay: Double
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var effectiveColor: Color {
        colorScheme == .dark ? mood.color : mood.lightModeColor
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark
                    ? AnyShapeStyle(.regularMaterial)
                    : AnyShapeStyle(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(effectiveColor.opacity(isSelected ? 0.07 : 0))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            effectiveColor.opacity(isSelected ? 0.30 : 0.10),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: effectiveColor.opacity(isSelected ? 0.15 : 0),
                    radius: 12, x: 0, y: 4
                )
        }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(effectiveColor.opacity(isSelected ? 0.20 : 0.08))
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    effectiveColor.opacity(isSelected ? 0.4 : 0.15),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(systemName: mood.icon)
                        .font(.system(.title2))
                        .foregroundColor(effectiveColor)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(mood.title)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(mood.subtitle)
                        .font(.system(.callout, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .strokeBorder(effectiveColor.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(effectiveColor)
                            .frame(width: 14, height: 14)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(16)
            .background(cardBackground)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}
