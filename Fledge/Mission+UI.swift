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
            Color(red: 0.06, green: 0.08, blue: 0.22),
            Color(red: 0.08, green: 0.06, blue: 0.18)
        ]
        case .lonely: return [
            Color(red: 0.16, green: 0.08, blue: 0.06),
            Color(red: 0.12, green: 0.06, blue: 0.08)
        ]
        case .ready: return [
            Color(red: 0.12, green: 0.06, blue: 0.06),
            Color(red: 0.18, green: 0.08, blue: 0.04)
        ]
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
