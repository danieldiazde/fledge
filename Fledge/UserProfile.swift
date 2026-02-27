//
//  UserProfile.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import Foundation
import SwiftUI
import Combine

class UserProfile: ObservableObject {

    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: "userName") }
    }
    @Published var city: String {
        didSet { UserDefaults.standard.set(city, forKey: "userCity") }
    }
    @Published var goal: String {
        didSet { UserDefaults.standard.set(goal, forKey: "userGoal") }
    }
    @Published var diet: String {
        didSet { UserDefaults.standard.set(diet, forKey: "userDiet") }
    }
    @Published var style: String {
        didSet { UserDefaults.standard.set(style, forKey: "userStyle") }
    }

    @AppStorage("totalXP") var totalXP: Int = 0

    init() {
        self.name  = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.city  = UserDefaults.standard.string(forKey: "userCity") ?? "Monterrey"
        self.goal  = UserDefaults.standard.string(forKey: "userGoal") ?? ""
        self.diet  = UserDefaults.standard.string(forKey: "userDiet") ?? ""
        self.style = UserDefaults.standard.string(forKey: "userStyle") ?? ""
    }

    var isComplete: Bool {
        !goal.isEmpty && !diet.isEmpty && !style.isEmpty
    }

    var displayName: String { name.isEmpty ? "you" : name }
    var displayCity: String { city.isEmpty ? "your city" : city }

    var relevantTags: [MissionTag] {
        var tags: [MissionTag] = []

        switch goal {
        case "Staying healthy":    tags += [.fitness, .wellbeing, .cooking]
        case "Saving money":       tags += [.budget, .cooking, .adultLife]
        case "Exploring the city": tags += [.city, .exploration, .navigation]
        case "Meeting people":     tags += [.social, .growth]
        default: break
        }

        switch diet {
        case "Vegetarian": tags += [.vegetarian, .cooking]
        case "Vegan":      tags += [.vegan, .cooking]
        default:           tags += [.cooking]
        }

        switch style {
        case "I like a clear plan":     tags += [.planner]
        case "I figure it out as I go": tags += [.spontaneous]
        default: break
        }

        return tags
    }

    func reset() {
        name  = ""
        city  = ""
        goal  = ""
        diet  = ""
        style = ""
    }
}

extension String {
    func personalized(name: String, city: String) -> String {
        let resolvedName = name.isEmpty ? "you" : name
        let resolvedCity = city.isEmpty ? "your city" : city
        return self
            .replacingOccurrences(of: "{name}", with: resolvedName)
            .replacingOccurrences(of: "{city}", with: resolvedCity)
    }
}
