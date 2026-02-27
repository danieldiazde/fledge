//
//  Mood+UI.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 24/02/26.
//

import SwiftUI

extension Mood {
    var icon: String {
        switch self {
        case .overwhelmed: return "cloud.drizzle"
        case .lonely: return "moon.stars"
        case .ready: return "wind"
        }
    }
    
    var title: String {
            switch self {
            case .overwhelmed: return "Overwhelmed"
            case .lonely: return "Lonely"
            case .ready: return "Ready"
            }
        }
    
    var subtitle: String {
        switch self {
        case .overwhelmed: return "A lot is happening right now."
        case .lonely: return "Missing people or feeling distant."
        case .ready: return "Energized and up for it."
        }
    }
    
    var color: Color {
        switch self {
        case .overwhelmed: return Color(red: 0.45, green: 0.55, blue: 0.85)
        case .lonely: return Color(red: 0.75, green: 0.55, blue: 0.35)
        case .ready: return Color.accentColor
        }
    }
    
    var lightModeColor: Color {
        switch self {
        case .overwhelmed: return Color(red: 0.22, green: 0.32, blue: 0.65)
        case .lonely: return Color(red: 0.58, green: 0.32, blue: 0.15)
        case .ready: return Color(red: 0.72, green: 0.32, blue: 0.20)
        }
    }
    
    var atmosphereColors: [Color] {
        switch self {
        case .overwhelmed: return [
            Color(red: 0.05, green: 0.07, blue: 0.24),
            Color(red: 0.03, green: 0.04, blue: 0.16)
        ]
        case .lonely: return [
            Color(red: 0.18, green: 0.08, blue: 0.14),
            Color(red: 0.10, green: 0.05, blue: 0.12)
        ]
        case .ready: return [
            Color(red: 0.04, green: 0.14, blue: 0.18),
            Color(red: 0.02, green: 0.08, blue: 0.14)
        ]
        }
    }

    var lightModeAtmosphereColors: [Color] {
        switch self {
        case .overwhelmed: return [
            Color(red: 0.84, green: 0.87, blue: 0.97),
            Color(red: 0.91, green: 0.93, blue: 0.99)
        ]
        case .lonely: return [
            // Warm peach-rose — golden hour before dark
            Color(red: 0.99, green: 0.91, blue: 0.87),
            Color(red: 0.97, green: 0.94, blue: 0.92)
        ]
        case .ready: return [
            // Fresh mint-sky — clear morning air
            Color(red: 0.87, green: 0.96, blue: 0.97),
            Color(red: 0.92, green: 0.97, blue: 0.99)
        ]
        }
    }

    // Radial accent glow color that sits on top of the sky
    var atmosphereGlowColor: Color {
        switch self {
        case .overwhelmed: return Color(red: 0.35, green: 0.45, blue: 0.95)
        case .lonely:      return Color(red: 0.85, green: 0.50, blue: 0.40)
        case .ready:       return Color(red: 0.25, green: 0.75, blue: 0.80)
        }
    }
}

extension Pillar {
    var icon: String {
        switch self {
        case .city:      return "map"
        case .adultMode: return "wrench.and.screwdriver"
        case .growth:    return "leaf"
        }
    }
}

extension ResourceType {
    var icon: String {
        switch self {
        case .app:     return "📱"
        case .place:   return "📍"
        case .tip:     return "💡"
        case .warning: return "⚠️"
        case .cost:    return "💰"
        }
    }
}

extension MissionResource {
    var icon: String {
        type.icon
    }
}
