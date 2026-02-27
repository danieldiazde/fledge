//
//  FledgeStyle.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 21/02/26.
//

import SwiftUI

struct HeroGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 28
    var tint: Color = .clear
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colorScheme == .dark
                        ? AnyShapeStyle(.thickMaterial)
                        : AnyShapeStyle(Color(red: 0.99, green: 0.97, blue: 0.94))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(tint.opacity(colorScheme == .dark ? 0.06 : 0.04))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.10)
                                    : Color.black.opacity(0.06),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.12 : 0.07),
                        radius: 16, x: 0, y: 6
                    )
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.06 : 0.04),
                        radius: 4, x: 0, y: 2
                    )
            }
    }
}

// MARK: - Pillar Colors
extension Pillar {
    /// Adaptive tint used throughout the main UI in light and dark mode.
    var color: Color {
        switch self {
        case .city:      return Color(red: 0.4, green: 0.55, blue: 0.9)
        case .adultMode: return Color.accentColor
        case .growth:    return Color(red: 0.3, green: 0.78, blue: 0.5)
        }
    }

    var lightModeColor: Color {
        switch self {
        case .city:      return Color(red: 0.25, green: 0.35, blue: 0.65)
        case .adultMode: return Color(red: 0.72, green: 0.32, blue: 0.20)
        case .growth:    return Color(red: 0.18, green: 0.52, blue: 0.35)
        }
    }

    /// Brighter variant used exclusively on the dark sky canvas, where
    /// standard pillar colors would appear too muted against near-black.
    var skyColor: Color {
        switch self {
        case .city:      return Color(red: 0.5, green: 0.65, blue: 1.0)
        case .adultMode: return Color(red: 1.0, green: 0.65, blue: 0.45)
        case .growth:    return Color(red: 0.5, green: 0.9,  blue: 0.65)
        }
    }

    var tagline: String {
        switch self {
        case .city:      return "Explore your new home"
        case .adultMode: return "Handle the essentials"
        case .growth:    return "Invest in yourself"
        }
    }
}

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var tint: Color = .clear
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.white)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(tint.opacity(0.04))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.06)
                                    : Color.black.opacity(0.07),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05),
                        radius: 8, x: 0, y: 3
                    )
            }
    }
}

// MARK: - Glass Card with Pillar Tint
struct PillarGlassCard: ViewModifier {
    var pillar: Pillar
    var cornerRadius: CGFloat = 20
    var isComplete: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var effectiveColor: Color {
        colorScheme == .dark ? pillar.color : pillar.lightModeColor
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.white)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(effectiveColor.opacity(
                                colorScheme == .dark
                                    ? (isComplete ? 0.04 : 0.08)
                                    : (isComplete ? 0.02 : 0.04)
                            ))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                effectiveColor.opacity(isComplete ? 0.12 : 0.20),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.08 : 0.06),
                        radius: 8, x: 0, y: 3
                    )
            }
    }
}

// MARK: - Atmospheric Background
struct AtmosphericBackground: ViewModifier {
    var accentColor: Color = .clear
    
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    LinearGradient(
                        colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    if accentColor != .clear {
                        RadialGradient(
                            colors: [accentColor.opacity(0.08), Color.clear],
                            center: .top,
                            startRadius: 0,
                            endRadius: 400
                        )
                        .ignoresSafeArea()
                    }
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func heroGlassCard(cornerRadius: CGFloat = 28, tint: Color = .clear) -> some View {
        modifier(HeroGlassCard(cornerRadius: cornerRadius, tint: tint))
    }
    
    func glassCard(cornerRadius: CGFloat = 20, tint: Color = .clear) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, tint: tint))
    }
    
    func pillarGlassCard(_ pillar: Pillar, cornerRadius: CGFloat = 20, isComplete: Bool = false) -> some View {
        modifier(PillarGlassCard(pillar: pillar, cornerRadius: cornerRadius, isComplete: isComplete))
    }
}
