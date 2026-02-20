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
    
    @Published var goal: String {
        didSet { UserDefaults.standard.set(goal, forKey: "userGoal") }
    }
    @Published var diet: String {
        didSet { UserDefaults.standard.set(diet, forKey: "userDiet") }
    }
    @Published var style: String {
        didSet { UserDefaults.standard.set(style, forKey: "userStyle") }
    }
    
    init() {
        self.goal = UserDefaults.standard.string(forKey: "userGoal") ?? ""
        self.diet = UserDefaults.standard.string(forKey: "userDiet") ?? ""
        self.style = UserDefaults.standard.string(forKey: "userStyle") ?? ""
    }
    
    var isComplete: Bool {
        !goal.isEmpty && !diet.isEmpty && !style.isEmpty
    }
    
    var relevantTags: [String] {
        var tags: [String] = []
        
        switch goal {
        case "Staying healthy": tags += ["fitness", "cooking"]
        case "Saving money": tags += ["budget", "cooking"]
        case "Exploring the city": tags += ["city", "social"]
        case "Meeting people": tags += ["social", "growth"]
        default: break
        }
        
        switch diet {
        case "Vegetarian": tags += ["vegetarian"]
        case "Vegan": tags += ["vegan"]
        default: tags += ["cooking"]
        }
        
        return tags
    }
    
    func reset() {
        goal = ""
        diet = ""
        style = ""
    }
}
