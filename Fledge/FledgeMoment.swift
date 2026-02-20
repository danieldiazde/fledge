//
//  FledgeMoment.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import Foundation

struct FledgeMoment {
    static let moments: [String] = [
        "You just did something your past self didn't know how to do.",
        "That's one less thing this city can throw at you.",
        "Most people never figure this out. You just did.",
        "Every expert was once exactly where you are.",
        "That feeling? Remember it. It gets bigger from here.",
        "You're not figuring out adulting. You're doing it.",
        "One more thing the new city can't take from you.",
        "That's not a small win. That's a real one.",
        "You moved somewhere new and you're making it work.",
        "This is what spreading your wings actually looks like."
    ]
    
    static func random() -> String {
        moments.randomElement() ?? moments[0]
    }
    
    
    static func forPillar(_ pillar: Pillar) -> String {
        switch pillar {
        case .city:
            return [
                "The city just got a little smaller.",
                "You found your footing. Now explore further.",
                "That route is yours now. The city is opening up."
            ].randomElement()!
        case .adultMode:
            return [
                "You just did something your past self didn't know how to do.",
                "That's one less thing adulting can throw at you.",
                "You're not figuring out adulting. You're doing it."
            ].randomElement()!
        case .growth:
            return [
                "That feeling? Remember it. It gets bigger from here.",
                "You moved somewhere new and you're making it work.",
                "This is what spreading your wings actually looks like."
            ].randomElement()!
        }
    }
}
